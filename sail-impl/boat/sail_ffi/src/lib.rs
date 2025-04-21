mod ffi;
mod sail_impl;
mod simulator;

// We need to have granular control over what the emulator can use to prevent application
// developers from messing around with Sail states.
pub use ffi::step;
pub use simulator::{Simulator, SIM_HANDLE};
