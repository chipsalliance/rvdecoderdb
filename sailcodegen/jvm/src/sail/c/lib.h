#pragma once
#include "sail.h"

// debug
unit print_instr(sail_string s);
unit print_reg(sail_string s);
unit print_platform(sail_string s);

// need to implement
mach_bits inst_fetch(mach_bits pc);
uint64_t readmem(uint64_t address, uint64_t satp);
unit writemem(uint64_t address, uint64_t data, uint64_t bytes, uint64_t satp);
bool exception_raised(unit);
uint64_t get_exception(unit);
unit fence_i(uint16_t pred, uint16_t succ);
bool is_reset(unit);

// GPRs
uint64_t get_resetval_x0(unit);
uint64_t get_resetval_x1(unit);
uint64_t get_resetval_x2(unit);
uint64_t get_resetval_x3(unit);
uint64_t get_resetval_x4(unit);
uint64_t get_resetval_x5(unit);
uint64_t get_resetval_x6(unit);
uint64_t get_resetval_x7(unit);
uint64_t get_resetval_x8(unit);
uint64_t get_resetval_x9(unit);
uint64_t get_resetval_x10(unit);
uint64_t get_resetval_x11(unit);
uint64_t get_resetval_x12(unit);
uint64_t get_resetval_x13(unit);
uint64_t get_resetval_x14(unit);
uint64_t get_resetval_x15(unit);
uint64_t get_resetval_x16(unit);
uint64_t get_resetval_x17(unit);
uint64_t get_resetval_x18(unit);
uint64_t get_resetval_x19(unit);
uint64_t get_resetval_x20(unit);
uint64_t get_resetval_x21(unit);
uint64_t get_resetval_x22(unit);
uint64_t get_resetval_x23(unit);
uint64_t get_resetval_x24(unit);
uint64_t get_resetval_x25(unit);
uint64_t get_resetval_x26(unit);
uint64_t get_resetval_x27(unit);
uint64_t get_resetval_x28(unit);
uint64_t get_resetval_x29(unit);
uint64_t get_resetval_x30(unit);
uint64_t get_resetval_x31(unit);
// CSRs
uint64_t get_resetval_mie(unit);
uint64_t get_resetval_mip(unit);
uint64_t get_resetval_mideleg(unit);
uint64_t get_resetval_mstatus(unit);
uint64_t get_resetval_mtvec(unit);
uint64_t get_resetval_mcause(unit);
uint64_t get_resetval_menvcfg(unit);
uint64_t get_resetval_senvcfg(unit);
uint64_t get_resetval_satp(unit);
uint64_t get_resetval_misa(unit);
uint64_t get_resetval_mtval(unit);
uint64_t get_resetval_mepc(unit);
uint64_t get_resetval_stvec(unit);
uint64_t get_resetval_sepc(unit);
uint64_t get_resetval_scause(unit);
uint64_t get_resetval_stval(unit);
uint64_t get_resetval_medeleg(unit);