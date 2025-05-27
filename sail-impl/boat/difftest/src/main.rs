use serde::Deserialize;
mod spike;

#[derive(Debug, Deserialize)]
struct CaseConfig {
    elf_path_glob: String,
    sail_args: Vec<String>,
    spike_args: Vec<String>,
}

fn main() {
    let cfg_raw = std::fs::read("./sail_difftest_config.json")
        .unwrap_or_else(|err| panic!("fail to read sail difftest config: {err}"));
    let cfg: CaseConfig = serde_json::from_slice(&cfg_raw)
        .unwrap_or_else(|err| panic!("fail to parse config: {err}"));
    let all_elf_files = glob::glob(&cfg.elf_path_glob)
        .unwrap_or_else(|err| panic!("invalid path glob {}: {}", cfg.elf_path_glob, err));
    let _ = all_elf_files.map(|path| {
        let path = path.unwrap_or_else(|err| panic!("glob leads to unreadable path: {err}"));
        let spike_log = spike::run_process(&cfg.spike_args, &path).unwrap();
    });
}
