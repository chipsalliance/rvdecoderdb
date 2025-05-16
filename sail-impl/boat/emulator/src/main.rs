use clap::Parser;
use sail_ffi::{SimulationException, Simulator, SimulatorParams};
use tracing::{event, Level};
use tracing_subscriber::{filter::LevelFilter, EnvFilter, FmtSubscriber};

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

    /// Exit when same instruction occur N time
    #[arg(long, default_value_t = 50)]
    max_same_instruction: u8,
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
                .with_default_directive(LevelFilter::INFO.into())
                .from_env_lossy(),
        )
        .init();

    let sim_handle =
        SimulatorParams::to_sim_handle(args.memory_size, args.max_same_instruction, args.elf_path);

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
