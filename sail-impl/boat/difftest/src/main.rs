use boat::{BoatEvent, BoatLog};
use serde::Deserialize;
use serde::Deserializer;
use spike::SpikeLog;
mod boat;
mod spike;

/// Describe the expected memory behavior for program exit
#[derive(Debug, Deserialize)]
struct EndPattern {
    // Memory action a EndPattern should capture. Support only "write" now.
    #[allow(dead_code)]
    action: String,
    // Hex string with "0x" prefix indicate the memory address a EndPattern should
    // capture
    #[serde(deserialize_with = "hex_to_u64")]
    memory_address: u64,
    // Hex string with "0x" prefix indicate the data value should be capture on the given memory address
    #[serde(deserialize_with = "hex_to_u64")]
    data: u64,
}

fn hex_to_u64<'de, D>(de: D) -> Result<u64, D::Error>
where
    D: Deserializer<'de>,
{
    let val: &str = Deserialize::deserialize(de)?;
    u64::from_str_radix(val.trim_start_matches("0x"), 16)
        .map_err(|err| serde::de::Error::custom(format!("cannot convert hex value to u64: {err}")))
}

#[derive(Debug, Deserialize)]
struct CaseConfig {
    elf_path_glob: String,
    boat_args: Vec<String>,
    spike_args: Vec<String>,
    end_pattern: EndPattern,
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
        let diff_result = diff(&spike_log, &boat_log, &cfg.end_pattern);
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

fn diff(spike_log: &SpikeLog, boat_log: &BoatLog, end_pattern: &EndPattern) -> DiffMeta {
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
    let test_end_pc = spike_log
        .has_memory_write_commits()
        .into_iter()
        .find_map(|log| {
            let (write_address, write_data) = log.commits.get_mem_write().unwrap();
            if write_address == end_pattern.memory_address && write_data == end_pattern.data {
                Some(log.pc)
            } else {
                None
            }
        });
    let Some(end_pc) = test_end_pc else {
        return DiffMeta::failed("Can't find any end pattern from spike log");
    };

    for spike_event in spike_log.iter() {
        if !is_reset {
            if spike_event.pc == reset_vector_addr {
                is_reset = true;
            } else {
                continue;
            }
        }

        if spike_event.pc == end_pc {
            break;
        }

        // ignore memory read write only commits
        if !spike_event.has_reg_write_commit() {
            continue;
        }

        let search_result =
            boat_log[boat_log_cursor..]
                .iter()
                .enumerate()
                .find_map(|(i, event)| match event {
                    BoatEvent::ArchState { pc, .. } => {
                        if *pc == spike_event.pc {
                            boat_log_cursor = i;
                            Some(event)
                        } else {
                            None
                        }
                    }
                    _ => None,
                });

        if search_result.is_none() {
            return DiffMeta::failed(indoc::formatdoc! {"
                At PC={:#018x} spike have following commit events that are not occur at boat side:

                {spike_event}
                ", spike_event.pc
            });
        }

        let search_result = search_result.unwrap();
        let BoatEvent::ArchState {
            reg_idx, data, pc, ..
        } = search_result
        else {
            unreachable!("internal error: we already filter boat event type at above")
        };

        let match_event = spike_event
            .get_register_type_commits()
            .into_iter()
            .find(|event| {
                let (idx, value) = event.get_register().unwrap();
                idx == *reg_idx && value == *data
            });

        if match_event.is_none() {
            return DiffMeta::failed(indoc::formatdoc! {"
                At PC={pc:#018x} boat write {data:#018x} to register x{reg_idx}, but this action was not found at spike side.

                Displaying Spike event dump:
                {spike_event:#?}

                Displaying Boat event dump:
                {search_result:#?}
            "});
        }
    }

    DiffMeta::passed()
}
