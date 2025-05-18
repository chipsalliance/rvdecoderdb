use clap::Parser;
use sail_ffi::{SimulationException, Simulator, SimulatorParams};
use std::fmt::Display;
use std::str::FromStr;
use tracing::{event, Level};
use tracing_subscriber::{EnvFilter, FmtSubscriber};

/// Simple program to greet a person
#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct Args {
    /// Name of the person to greet
    #[arg(short, long)]
    elf_path: String,

    /// Number of times to greet
    #[arg(short, long, default_value_t = MemorySize(0xa000_0000))]
    memory_size: MemorySize,

    /// Exit when same instruction occur N time
    #[arg(long, default_value_t = 50)]
    max_same_instruction: u8,

    #[arg(short, long, action = clap::ArgAction::Count)]
    verbose: u8,
}

#[derive(Debug, Clone)]
struct MemorySize(usize);
impl MemorySize {
    fn to_usize(self) -> usize {
        self.0
    }

    fn as_usize(&self) -> usize {
        self.0
    }
}

impl Display for MemorySize {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_usize())
    }
}

impl From<usize> for MemorySize {
    fn from(value: usize) -> Self {
        Self(value)
    }
}

impl FromStr for MemorySize {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        if s.starts_with("0x") {
            let raw = s.trim_start_matches("0x");
            let final_mem_size: usize = match raw.len() {
                8 => {
                    let result = u32::from_str_radix(raw, 16);
                    if let Err(err) = result {
                        return Err(format!("invalid hex string {s}: {err}"));
                    }
                    result
                        .unwrap()
                        .try_into()
                        .expect("value is not a unsigned 32 bit value")
                }
                16 => {
                    let result = u64::from_str_radix(raw, 16);
                    if let Err(err) = result {
                        return Err(format!("invalid hex string {s}: {err}"));
                    }
                    result
                        .unwrap()
                        .try_into()
                        .expect("you specify a 64 bit value but your system doesn't support it")
                }
                _ => {
                    return Err(format!(
                        "fail decoding hex {} to usize: only support 32-bit or 64-bit memory size",
                        s
                    ))
                }
            };
            Ok(MemorySize(final_mem_size))
        } else {
            let result: Result<usize, _> = s.parse();
            if let Err(err) = result {
                Err(format!("fail converting digit {} to usize: {}", s, err))
            } else {
                Ok(MemorySize(result.unwrap()))
            }
        }
    }
}

fn main() {
    let args = Args::parse();

    FmtSubscriber::builder()
        .without_time()
        .with_ansi(true)
        .with_line_number(false)
        .with_env_filter(
            EnvFilter::builder()
                .with_env_var("SAIL_EMU_LOG_LEVEL")
                .with_default_directive(match args.verbose {
                    0 => Level::INFO.into(),
                    1 => Level::DEBUG.into(),
                    _ => Level::TRACE.into(),
                })
                .from_env_lossy(),
        )
        .init();

    let sim_handle = SimulatorParams::to_sim_handle(
        args.memory_size.to_usize(),
        args.max_same_instruction,
        args.elf_path,
    );

    loop {
        unsafe {
            Simulator::step();
        }

        let step_result = sim_handle.with(|sim| sim.check_step());

        if let Err(exception) = step_result {
            match exception {
                SimulationException::Exited => {
                    event!(Level::INFO, "Simulation exit successfully");
                }
                other => {
                    event!(Level::ERROR, "Simulation exit with error: {other}")
                }
            };
            break;
        }
    }

    sim_handle.with(|sim| sim.print_statistic());
}
