use clap::Parser;
use sail_ffi::{Simulator, SIM_HANDLE};

/// Simple program to greet a person
#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct Args {
    /// Name of the person to greet
    #[arg(short, long)]
    elf_path: String,

    /// Number of times to greet
    #[arg(short, long, default_value_t = 0xa000_0000)]
    memory_size: usize,
}

fn main() {
    let args = Args::parse();

    // TODO: configurable from Clap
    let simulator = Simulator::new(args.memory_size, &args.elf_path);
    SIM_HANDLE.init(|| simulator);

    loop {
        sail_ffi::step();

        let step_result = SIM_HANDLE.with(|sim| sim.check_step());

        if let Err(_) = step_result {
            break;
        }
    }
}
