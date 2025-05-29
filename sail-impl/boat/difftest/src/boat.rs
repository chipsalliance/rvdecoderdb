use anyhow::Context;
use serde::Deserialize;
use std::fmt::Display;

pub type BoatLog = Vec<BoatEvent>;

pub fn run_process(
    args: &[String],
    elf_path: impl AsRef<std::ffi::OsStr>,
) -> anyhow::Result<BoatLog> {
    let boat_exec = which::which("boat").with_context(|| "boat exec not found")?;

    const EVENT_PATH: &str = "./boat_trace_event.jsonl";
    let result = std::process::Command::new(&boat_exec)
        .arg("-vvv")
        .arg("--elf-path")
        .arg(&elf_path)
        .arg("--output-log-path")
        .arg(EVENT_PATH)
        .args(args)
        .output()
        .with_context(|| "fail exeuting boat")?;

    if !result.status.success() {
        anyhow::bail!(
            "fail to execute boat with args {args:?} for elf {}",
            elf_path.as_ref().to_str().unwrap()
        );
    }

    let trace_event =
        std::fs::read(EVENT_PATH).with_context(|| format!("fail reading {EVENT_PATH}"))?;

    let boat_log = get_boat_events(&trace_event);

    Ok(boat_log)
}

fn get_boat_events(raw: impl AsRef<[u8]>) -> BoatLog {
    let log_raw = String::from_utf8_lossy(raw.as_ref());
    let mut events = Vec::new();

    for (line_number, line) in log_raw.lines().enumerate() {
        let log_line: BoatLogLine = serde_json::from_str(line)
            .unwrap_or_else(|err| panic!("fail parsing boat log at line {line_number}: {err}"));
        events.push(log_line.fields)
    }

    events
}

#[derive(Debug, Deserialize)]
pub struct BoatLogLine {
    pub fields: BoatEvent,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
#[serde(tag = "event_type")]
pub enum BoatEvent {
    #[serde(rename = "physical_memory")]
    PhysicalMemory {
        action: String,
        bytes: u8,
        address: u64,
    },
    #[serde(rename = "arch_state")]
    ArchState {
        action: String,
        pc: u64,
        reg_idx: u8,
        data: u64,
    },
    #[serde(rename = "instruction_fetch")]
    InstructionFetch { data: u32 },
    #[serde(rename = "reset_vector")]
    ResetVector { new_addr: u64 },
}

impl Display for BoatEvent {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::ArchState {
                action,
                pc,
                reg_idx,
                data,
            } => indoc::writedoc!(
                f,
                "PC={pc:#018x} {action} to register [x{reg_idx}] with [{data:#018x}]"
            ),
            _ => write!(f, "{self:#?}"),
        }
    }
}

impl BoatEvent {
    pub fn get_reset_vector(&self) -> Option<u64> {
        match self {
            Self::ResetVector { new_addr } => Some(*new_addr),
            _ => None,
        }
    }
}

#[test]
fn test_parsing_boat_log() {
    let mut d = std::path::PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    d.push("assets/boat_trace_event.jsonl");
    let sample_log = std::fs::read(d).unwrap();
    assert!(!sample_log.is_empty());
    let log = get_boat_events(sample_log);
    assert!(!log.is_empty());
    dbg!(log);
}
