use boat::{BoatEvent, BoatLog};
use serde::Deserialize;
use spike::{SpikeLog, SpikeRegister};
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
    let mut is_reset = false;

    // spike contains vendored bootrom but doesn't provide a way to remove it.
    // so we need to compares commit log from when the boat emulator run reset_vector
    let reset_vector_addr = boat_log
        .iter()
        .find_map(|event| event.get_reset_vector())
        .unwrap_or_else(|| {
            unreachable!("reset_vector event not found");
        });

    for spike_event in spike_log {
        if !is_reset {
            if spike_event.pc == reset_vector_addr {
                is_reset = true;
            } else {
                continue;
            }
        }

        if spike_event.reg.is_empty() {
            continue;
        }

        let search_result = boat_log[boat_log_cursor..]
            .iter()
            .enumerate()
            .filter(|(i, event)| match event {
                BoatEvent::ArchState { pc, .. } => {
                    if *pc == spike_event.pc {
                        boat_log_cursor = *i;
                        true
                    } else {
                        false
                    }
                }
                _ => false,
            })
            .collect::<Vec<_>>();

        if search_result.is_empty() {
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
            return DiffMeta::failed(indoc::formatdoc! {"
                At PC={:#018x} spike have following actions which are not applied at boat side:

                Displaying error message: {}

                Displaying Spike event dump:
                {spike_event:#?}
                ", spike_event.pc, expect
            });
        }

        for (_, event) in search_result {
            let BoatEvent::ArchState {
                reg_idx, data, pc, ..
            } = event
            else {
                unreachable!("we already filter at above")
            };

            let match_event = spike_event
                .reg
                .iter()
                .find(|SpikeRegister { name, value }| {
                    name.as_str() == format!("x{reg_idx}") && value == data
                });

            if match_event.is_none() {
                return DiffMeta::failed(indoc::formatdoc! {"
                    At PC={pc:#018x} boat write {data:#018x} to register x{reg_idx}, but this action was not found at spike side.

                    Displaying Spike event dump:
                    {spike_event:#?}

                    Displaying Boat event dump:
                    {event:#?}
                "});
            }
        }
    }

    DiffMeta::passed()
}
