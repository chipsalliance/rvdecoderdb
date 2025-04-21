#![allow(non_upper_case_globals)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]

include!(concat!(env!("OUT_DIR"), "/sail_expose.rs"));

use crate::sail_impl::SAIL_UNIT;
use std::sync::Once;

// Internally ensure reset_vector will not be unintentionally called twice
// TODO: left an public interface `force_reset_vector`?
static DONE_RESET: Once = Once::new();

pub(crate) fn reset_vector(entry: u64) {
    // TODO! Friendly reminder here
    if DONE_RESET.is_completed() {
        panic!("'reset_vector' called twice");
    }

    DONE_RESET.call_once(|| ());

    unsafe {
        zPC = entry;
    }
}

pub fn step() {
    unsafe { crate::ffi::zstep(SAIL_UNIT) };
}
