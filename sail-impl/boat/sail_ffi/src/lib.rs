mod ffi;
mod model;
mod simulator;

// We need to have granular control over what the emulator can use to prevent application
// developers from messing around with Sail states.
pub use simulator::{SimulationException, Simulator, SimulatorParams};
