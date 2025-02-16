#include "sail.h"

#include <stdint.h>
#include <stdio.h>

unit print_instr(sail_string s)
{
  printf("%s\n", s);
  return UNIT;
}

unit print_platform(sail_string s)
{
  printf("%s\n", s);
  return UNIT;
}

unit print_reg(sail_string s)
{
  printf("%s\n", s);
  return UNIT;
}

mach_bits inst_fetch(mach_bits pc) {
  printf("inst_fetch: pc = %lx\n", pc);
  return UINT64_C(0x0000000F);
}

uint64_t readmem(uint64_t virtaddress, uint64_t rd_val, uint64_t satp) {
  printf("read_mem: virtaddress = %lx, rd_val = %lx, satp = %lx\n", virtaddress, rd_val, satp);
  return UINT64_C(0x0000000000000000);
}

unit writemem(uint64_t virtaddress, uint64_t data, uint64_t bytes, uint64_t satp) {
  printf("write_mem: address = %lx, data = %lx, bytes = %lx, satp = %lx\n", virtaddress, data, bytes, satp);
}

bool exception_raised(unit) {
  return false;
}

uint64_t get_exception(unit) {
  return 0x0000;
}

uint64_t get_mip(unit) {
  return 0x0000;
}

uint64_t get_sip(unit) {
  return 0x0000;
}

unit fence_i(uint16_t pred, uint16_t succ) {
  printf("fence_ii: pred = %x, succ = %x\n", pred, succ);
}

bool is_reset(unit) {
  return false;
}

uint64_t get_resetval_x0(unit u) { return 0; }
uint64_t get_resetval_x1(unit u) { return 0; }
uint64_t get_resetval_x2(unit u) { return 0; }
uint64_t get_resetval_x3(unit u) { return 0; }
uint64_t get_resetval_x4(unit u) { return 0; }
uint64_t get_resetval_x5(unit u) { return 0; }
uint64_t get_resetval_x6(unit u) { return 0; }
uint64_t get_resetval_x7(unit u) { return 0; }
uint64_t get_resetval_x8(unit u) { return 0; }
uint64_t get_resetval_x9(unit u) { return 0; }
uint64_t get_resetval_x10(unit u) { return 0; }
uint64_t get_resetval_x11(unit u) { return 0; }
uint64_t get_resetval_x12(unit u) { return 0; }
uint64_t get_resetval_x13(unit u) { return 0; }
uint64_t get_resetval_x14(unit u) { return 0; }
uint64_t get_resetval_x15(unit u) { return 0; }
uint64_t get_resetval_x16(unit u) { return 0; }
uint64_t get_resetval_x17(unit u) { return 0; }
uint64_t get_resetval_x18(unit u) { return 0; }
uint64_t get_resetval_x19(unit u) { return 0; }
uint64_t get_resetval_x20(unit u) { return 0; }
uint64_t get_resetval_x21(unit u) { return 0; }
uint64_t get_resetval_x22(unit u) { return 0; }
uint64_t get_resetval_x23(unit u) { return 0; }
uint64_t get_resetval_x24(unit u) { return 0; }
uint64_t get_resetval_x25(unit u) { return 0; }
uint64_t get_resetval_x26(unit u) { return 0; }
uint64_t get_resetval_x27(unit u) { return 0; }
uint64_t get_resetval_x28(unit u) { return 0; }
uint64_t get_resetval_x29(unit u) { return 0; }
uint64_t get_resetval_x30(unit u) { return 0; }
uint64_t get_resetval_x31(unit u) { return 0; }
// CSRs
uint64_t get_resetval_mie(unit u) { return 0; }
uint64_t get_resetval_mip(unit u) { return 0; }
uint64_t get_resetval_mideleg(unit u) { return 0; }
uint64_t get_resetval_mstatus(unit u) { return 0; }
uint64_t get_resetval_mtvec(unit u) { return 0; }
uint64_t get_resetval_mcause(unit u) { return 0; }
uint64_t get_resetval_menvcfg(unit u) { return 0; }
uint64_t get_resetval_senvcfg(unit u) { return 0; }
uint64_t get_resetval_satp(unit u) { return 0; }
uint64_t get_resetval_misa(unit u) { return 0; }
uint64_t get_resetval_mtval(unit u) { return 0; }
uint64_t get_resetval_mepc(unit u) { return 0; }
uint64_t get_resetval_stvec(unit u) { return 0; }
uint64_t get_resetval_sepc(unit u) { return 0; }
uint64_t get_resetval_scause(unit u) { return 0; }
uint64_t get_resetval_stval(unit u) { return 0; }
uint64_t get_resetval_medeleg(unit u) { return 0; }