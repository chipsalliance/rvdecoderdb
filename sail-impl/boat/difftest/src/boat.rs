use serde::Deserialize;

pub type BoatLog = Vec<BoatEvent>;

pub fn run_process(
    args: &[String],
    elf_path: impl AsRef<std::ffi::OsStr>,
) -> Result<BoatLog, String> {
    let boat_exec = which::which("boat").unwrap_or_else(|err| panic!("boat exec not found: {err}"));

    const EVENT_PATH: &str = "./boat_trace_event.jsonl";
    let result = std::process::Command::new(&boat_exec)
        .arg("-vvv")
        .arg("--elf-path")
        .arg(&elf_path)
        .arg("--output-log-path")
        .arg(EVENT_PATH)
        .args(args)
        .output()
        .unwrap_or_else(|err| panic!("fail exeuting boat: {err}"));

    if !result.status.success() {
        return Err(format!(
            "fail to execute '{boat_exec:?}' with args {args:?} for elf {}",
            elf_path.as_ref().to_str().unwrap()
        ));
    }

    let trace_event =
        std::fs::read(EVENT_PATH).unwrap_or_else(|err| panic!("fail reading {EVENT_PATH}: {err}"));

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
        current_value: u64,
    },
    #[serde(rename = "instruction_fetch")]
    InstructionFetch { data: u32 },
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
