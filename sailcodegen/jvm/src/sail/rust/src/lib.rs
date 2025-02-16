#![no_main]
extern crate goblin;

use goblin::elf::Elf;
use std::ffi::CString;
use std::fs;
use std::env;
use std::time::Duration;
use std::thread;

#[allow(non_snake_case)]

use std::ffi::CStr;
use std::os::raw::{c_char, c_void};

type unit = i32;
const UNIT: unit = 0;
type mach_bits = u64;

#[no_mangle]
fn print_instr(s: *const c_char) -> unit {
    unsafe {
        let c_str = CStr::from_ptr(s);
        println!("{}", c_str.to_string_lossy());
    }
    UNIT
}

#[no_mangle]
fn print_platform(s: *const c_char) -> unit {
    unsafe {
        let c_str = CStr::from_ptr(s);
        println!("{}", c_str.to_string_lossy());
    }
    UNIT
}

#[no_mangle]
fn print_reg(s: *const c_char) -> unit {
    unsafe {
        let c_str = CStr::from_ptr(s);
        println!("{}", c_str.to_string_lossy());
    }
    UNIT
}

#[no_mangle]
fn inst_fetch(pc: mach_bits) -> mach_bits {
    println!("inst_fetch: pcc = {:x}", pc);
    0x10b51063
}

#[no_mangle]
fn readmem(virtaddress: u64, rd_val: u64, satp: u64) -> u64 {
    println!("read_mem: virtaddress = {:x}, rd_val = {:x}, satp = {:x}", virtaddress, rd_val, satp);
    0x0000000000000000
}

#[no_mangle]
fn writemem(virtaddress: u64, data: u64, bytes: u64, satp: u64) -> unit {
    println!("write_mem: address = {:x}, data = {:x}, bytes = {:x}, satp = {:x}", 
        virtaddress, data, bytes, satp);
    UNIT
}

#[no_mangle]
fn exception_raised(_u: unit) -> bool {
    false
}

#[no_mangle]
fn get_exception(_u: unit) -> u64 {
    0x0000
}

#[no_mangle]
fn get_mip(_u: unit) -> u64 {
    0x0000
}

#[no_mangle]
fn get_sip(_u: unit) -> u64 {
    0x0000
}

#[no_mangle]
fn fence_i(pred: u16, succ: u16) -> unit {
    println!("fence_i: pred = {:x}, succ = {:x}", pred, succ);
    UNIT
}

#[no_mangle]
fn is_reset(_u: unit) -> bool {
    false
}

// GPRs
#[no_mangle]
fn get_resetval_x0(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x1(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x2(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x3(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x4(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x5(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x6(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x7(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x8(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x9(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x10(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x11(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x12(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x13(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x14(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x15(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x16(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x17(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x18(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x19(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x20(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x21(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x22(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x23(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x24(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x25(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x26(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x27(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x28(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x29(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x30(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_x31(_u: unit) -> u64 { 0 }

// CSRs
#[no_mangle]
fn get_resetval_mie(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_mip(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_mideleg(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_mstatus(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_mtvec(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_mcause(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_menvcfg(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_senvcfg(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_satp(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_misa(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_mtval(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_mepc(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_stvec(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_sepc(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_scause(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_stval(_u: unit) -> u64 { 0 }
#[no_mangle]
fn get_resetval_medeleg(_u: unit) -> u64 { 0 }

#[link(name = "sail")]
extern "C" {
    fn model_init();
    fn zstep();
}

#[no_mangle]
pub fn main() {
    unsafe {
        model_init();
    }

    loop {
        unsafe {
            zstep();
        }
        thread::sleep(Duration::from_millis(100));
    }
}
