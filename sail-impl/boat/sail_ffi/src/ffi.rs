use crate::model;
use crate::model::{MarchBits, Unit, SAIL_UNIT};
use crate::simulator::SIM_HANDLE;
use std::ffi::{c_char, CStr};
use tracing::{event, Level};

/// `reset_vector` set PC to given `entry` address. This function remain unsafe to make sure end
/// user knows the side effect of this function.
pub(crate) unsafe fn reset_vector(entry: u64) {
    unsafe {
        model::zPC = entry;
    }
}

#[unsafe(no_mangle)]
unsafe extern "C" fn inst_fetch(pc: MarchBits) -> MarchBits {
    SIM_HANDLE.with(|core| core.inst_fetch(pc))
}

#[unsafe(no_mangle)]
unsafe extern "C" fn phy_read_byte(address: u64) -> u8 {
    SIM_HANDLE.with(|core| u8::from_le_bytes(core.phy_readmem(address)))
}

#[unsafe(no_mangle)]
unsafe extern "C" fn phy_read_half_word(address: u64) -> u16 {
    SIM_HANDLE.with(|core| u16::from_le_bytes(core.phy_readmem(address)))
}

#[unsafe(no_mangle)]
unsafe extern "C" fn phy_read_word(address: u64) -> u32 {
    SIM_HANDLE.with(|core| u32::from_le_bytes(core.phy_readmem(address)))
}

#[unsafe(no_mangle)]
unsafe extern "C" fn phy_read_double_word(address: u64) -> u64 {
    SIM_HANDLE.with(|core| u64::from_le_bytes(core.phy_readmem(address)))
}

#[unsafe(no_mangle)]
unsafe extern "C" fn phy_write_byte(address: u64, data: u8) -> Unit {
    SIM_HANDLE.with(|core| {
        core.phy_write_mem(address, data);
        SAIL_UNIT
    })
}

#[unsafe(no_mangle)]
unsafe extern "C" fn phy_write_half_word(address: u64, data: u16) -> Unit {
    SIM_HANDLE.with(|core| {
        core.phy_write_mem(address, data);
        SAIL_UNIT
    })
}

#[unsafe(no_mangle)]
unsafe extern "C" fn phy_write_word(address: u64, data: u32) -> Unit {
    SIM_HANDLE.with(|core| {
        core.phy_write_mem(address, data);
        SAIL_UNIT
    })
}

#[unsafe(no_mangle)]
unsafe extern "C" fn phy_write_double_word(address: u64, data: u64) -> Unit {
    SIM_HANDLE.with(|core| {
        core.phy_write_mem(address, data);
        SAIL_UNIT
    })
}

#[unsafe(no_mangle)]
unsafe extern "C" fn exception_raised(_: Unit) -> bool {
    SIM_HANDLE.with(|core| core.exception_raised())
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_exception(_: Unit) -> u64 {
    SIM_HANDLE.with(|core| core.get_exception())
}

#[unsafe(no_mangle)]
unsafe extern "C" fn fence_i(pred: u16, succ: u16) -> Unit {
    SIM_HANDLE.with(|core| {
        core.fence_i(pred, succ);
        SAIL_UNIT
    })
}

#[unsafe(no_mangle)]
unsafe extern "C" fn is_reset(_: Unit) -> bool {
    SIM_HANDLE.with(|core| core.is_reset())
}

#[unsafe(no_mangle)]
unsafe extern "C" fn print_line(s: *const c_char) -> Unit {
    unsafe {
        let sail_str = CStr::from_ptr(s).to_string_lossy();
        event!(Level::DEBUG, "sail_print_line: {}", sail_str);
    };
    SAIL_UNIT
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x0(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x1(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x2(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x3(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x4(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x5(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x6(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x7(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x8(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x9(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x10(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x11(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x12(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x13(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x14(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x15(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x16(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x17(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x18(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x19(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x20(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x21(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x22(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x23(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x24(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x25(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x26(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x27(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x28(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x29(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x30(_: Unit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x31(_: Unit) -> u64 {
    0
}

/// `get_pc` is the current value of Sail model internal `PC` register.
pub(crate) fn get_pc() -> MarchBits {
    unsafe { model::zPC }
}

#[unsafe(no_mangle)]
unsafe extern "C" fn write_GPR_hook(reg_idx: u8, data: u64) -> Unit {
    SIM_HANDLE.with(|core| {
        core.write_register(reg_idx, data);
        SAIL_UNIT
    })
}
