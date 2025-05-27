use std::fmt::Display;

pub fn run_process(
    args: &[String],
    elf_path: impl AsRef<std::ffi::OsStr>,
) -> Result<SpikeLog, String> {
    let spike_exec =
        which::which("spike").unwrap_or_else(|err| panic!("spike exec not found: {err}"));

    let result = std::process::Command::new(&spike_exec)
        .args(args)
        .arg(&elf_path)
        .output()
        .unwrap_or_else(|err| panic!("fail exeuting spike: {err}"));

    if !result.status.success() {
        println!("{}", String::from_utf8_lossy(&result.stderr));
        return Err(format!(
            "fail to execute '{spike_exec:?}' with args {} for elf {}",
            args.join(" "),
            elf_path.as_ref().to_str().unwrap()
        ));
    }

    let stdout = String::from_utf8_lossy(&result.stderr);
    let spike_log_ast = parse_spike_log(stdout);

    Ok(spike_log_ast)
}

fn parse_spike_log(log: impl AsRef<str>) -> SpikeLog {
    log.as_ref()
        .lines()
        .enumerate()
        .map(|(line_number, line)| match SpikeLogSyntax::parse(line) {
            Err(err) => {
                panic!("fail parsing line at line {line_number}: {err}. Original line: '{line}'")
            }
            Ok(ast) => ast,
        })
        .collect()
}

pub type SpikeLog = Vec<SpikeLogSyntax>;

#[derive(Debug, Default)]
pub struct SpikeLogSyntax {
    pub core: u8,
    pub privilege: u8,
    pub pc: u64,
    pub instruction: u32,
    // register name -> rd value
    pub reg: Vec<SpikeRegister>,
}

#[derive(Debug)]
pub struct SpikeRegister {
    pub name: String,
    pub value: u64,
}

impl SpikeRegister {
    fn new(n: impl std::fmt::Display, v: u64) -> Self {
        Self {
            name: n.to_string(),
            value: v,
        }
    }
}

enum ParseCursor<'a> {
    Core,
    Priv,
    Pc,
    Insn,
    RegParseBegin,
    RegParseName(&'a str),
    Error(String),
}

struct ParseContext<'a> {
    cursor: ParseCursor<'a>,
    state: SpikeLogSyntax,
}

impl Default for ParseContext<'_> {
    fn default() -> Self {
        Self {
            cursor: ParseCursor::Core,
            state: SpikeLogSyntax::default(),
        }
    }
}

impl ParseContext<'_> {
    fn new() -> Self {
        Self::default()
    }

    fn to_spike_log(self) -> Result<SpikeLogSyntax, String> {
        match self.cursor {
            ParseCursor::Error(err) => Err(err),
            _ => Ok(self.state),
        }
    }
}

impl SpikeLogSyntax {
    fn parse<'a>(line: &'a str) -> Result<Self, String> {
        fn to_error<'a>(expect: &str, actual: &str, err: impl Display) -> ParseCursor<'a> {
            ParseCursor::Error(format!("expect {expect}, get '{actual}': {err}"))
        }

        let ctx: ParseContext = line.trim().split(" ").filter(|part| !part.is_empty()).fold(
            ParseContext::new(),
            |mut ctx, elem| {
                match ctx.cursor {
                    // skip literal "core"
                    ParseCursor::Core if elem == "core" => ctx,
                    // vec[0] is core id. core id always comes with ":", strip it here
                    ParseCursor::Core => {
                        if !elem.ends_with(":") {
                            ctx.cursor =
                                to_error("':' suffixed string", elem, "core_id not ends with ':'");
                            return ctx;
                        }

                        match (&elem[0..elem.len() - 1]).parse::<u8>() {
                            Ok(v) => {
                                ctx.state.core = v;
                                ctx.cursor = ParseCursor::Priv;
                                ctx
                            }
                            Err(err) => {
                                ctx.cursor = to_error("u8 value core_id", elem, err);
                                ctx
                            }
                        }
                    }
                    ParseCursor::Priv => match elem.parse::<u8>() {
                        Ok(priv_id) => {
                            ctx.state.privilege = priv_id;
                            ctx.cursor = ParseCursor::Pc;
                            ctx
                        }
                        Err(err) => {
                            ctx.cursor = to_error("u8 value priv_id", elem, err);
                            ctx
                        }
                    },
                    ParseCursor::Pc => {
                        if !elem.starts_with("0x") {
                            ctx.cursor =
                                to_error("hex string", elem, "pc value not prefixed with '0x'");
                            return ctx;
                        };

                        match u64::from_str_radix(elem.trim_start_matches("0x"), 16) {
                            Ok(pc) => {
                                ctx.state.pc = pc;
                                ctx.cursor = ParseCursor::Insn;
                                ctx
                            }
                            Err(err) => {
                                ctx.cursor = to_error("u64 value pc", elem, err);
                                ctx
                            }
                        }
                    }
                    // vec[3] is instruction decode, it always has surrounding parentheses
                    ParseCursor::Insn => {
                        if !elem.starts_with("(0x") {
                            ctx.cursor = to_error(
                                "parentheses surrounding hex string",
                                elem,
                                "instruction not started with '(0x'",
                            );
                            return ctx;
                        };

                        if !elem.ends_with(")") {
                            ctx.cursor = to_error(
                                "parentheses surrounding hex string",
                                elem,
                                "instruction not ends with ')'",
                            );
                            return ctx;
                        };

                        match u32::from_str_radix(&elem[3..elem.len() - 1], 16) {
                            Ok(insn) => {
                                ctx.state.instruction = insn;
                                ctx.cursor = ParseCursor::RegParseBegin;
                                ctx
                            }
                            Err(err) => {
                                ctx.cursor = to_error("u32 value instruction", elem, err);
                                ctx
                            }
                        }
                    }
                    // then all other parts are register change, memory load and memory write
                    // spike handle memory in undocumented way and we don't need to compare memory
                    // behavior to spike, so trim memory here
                    ParseCursor::RegParseBegin if elem != "mem" && !elem.starts_with("0x") => {
                        ctx.cursor = ParseCursor::RegParseName(elem);
                        ctx
                    }
                    ParseCursor::RegParseName(reg_name) => {
                        if !elem.starts_with("0x") {
                            ctx.cursor =
                                to_error("hex string", elem, "pc value not prefixed with '0x'");
                            return ctx;
                        };

                        match u64::from_str_radix(elem.trim_start_matches("0x"), 16) {
                            Ok(reg_val) => {
                                ctx.cursor = ParseCursor::RegParseBegin;
                                ctx.state.reg.push(SpikeRegister::new(reg_name, reg_val));
                                ctx
                            }
                            Err(err) => {
                                ctx.cursor =
                                    to_error("u64 value register_value", elem, err.to_string());
                                ctx
                            }
                        }
                    }
                    // passthrough error
                    _ => ctx,
                }
            },
        );

        ctx.to_spike_log()
    }
}

#[test]
fn test_parsing_spike_log_ast() {
    let mut d = std::path::PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    d.push("assets/example.spike.log");
    let sample_log = std::fs::read(d).unwrap();
    assert!(!sample_log.is_empty());
    let raw = String::from_utf8_lossy(&sample_log);
    let ast = parse_spike_log(&raw);
    assert!(!ast.is_empty());
    dbg!(ast);
}
