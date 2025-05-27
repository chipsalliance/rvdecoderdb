use boat::{BoatEvent, BoatLog};
use serde::Deserialize;
use spike::SpikeLog;
mod boat;
mod spike;

#[derive(Debug, Deserialize)]
struct CaseConfig {
    elf_path_glob: String,
    boat_args: Vec<String>,
    spike_args: Vec<String>,
}

fn main() {
    let cfg_raw = std::fs::read("./sail_difftest_config.json")
        .unwrap_or_else(|err| panic!("fail to read sail difftest config: {err}"));
    let cfg: CaseConfig = serde_json::from_slice(&cfg_raw)
        .unwrap_or_else(|err| panic!("fail to parse config: {err}"));
    let all_elf_files = glob::glob(&cfg.elf_path_glob)
        .unwrap_or_else(|err| panic!("invalid path glob {}: {}", cfg.elf_path_glob, err));
    all_elf_files.for_each(|path| {
        let path = path.unwrap_or_else(|err| panic!("glob leads to unreadable path: {err}"));
        println!("Running elf {path:?}");
        let spike_log = spike::run_process(&cfg.spike_args, &path).unwrap();
        let boat_log = boat::run_process(&cfg.boat_args, &path).unwrap();
        let diff_result = diff(&spike_log, &boat_log);
        if !diff_result.is_same {
            panic!("\n{}\n", diff_result.context);
        } else {
            println!("difftest pass")
        }
    });
}

struct DiffMeta {
    is_same: bool,
    context: String,
}

impl DiffMeta {
    fn passed() -> Self {
        Self {
            is_same: true,
            context: String::new(),
        }
    }

    fn failed(ctx: impl ToString) -> Self {
        Self {
            is_same: false,
            context: ctx.to_string(),
        }
    }
}

fn diff(spike_log: &SpikeLog, boat_log: &BoatLog) -> DiffMeta {
    assert!(!spike_log.is_empty());
    assert!(!boat_log.is_empty());

    let mut boat_log_cursor = 0;

    for spike_event in spike_log {
        if spike_event.reg.is_empty() {
            continue;
        }

        let search_result = boat_log[boat_log_cursor..]
            .iter()
            .enumerate()
            .find(|(i, event)| match event {
                BoatEvent::ArchState {
                    action: _,
                    pc,
                    reg_idx: _,
                    current_value: _,
                } => {
                    if *pc == spike_event.pc {
                        boat_log_cursor = *i;
                        true
                    } else {
                        false
                    }
                }
                _ => false,
            });

        if search_result.is_none() {
            let expect = spike_event
                .reg
                .iter()
                .map(|reg| {
                    format!(
                        "* register write to ({}) with value: {}",
                        reg.name, reg.value
                    )
                })
                .collect::<Vec<String>>()
                .join("\n");
            return DiffMeta::failed(format!(
                "At PC={} spike have following actions which are not applied at boat side:\n\n{}",
                spike_event.pc, expect
            ));
        }
    }

    DiffMeta::passed()
}
