#include <stdbool.h>
#include <stdint.h>

typedef char *sail_string;
typedef int unit;

// debug
unit print_line(sail_string s);

// Exec
uint32_t inst_fetch(uint64_t pc);
unit fence_i(uint8_t pred, uint8_t succ);
bool is_reset(unit);

// phy_read* API all have one argument `address` with `bits(64)` width, return
// specific length value from that given address.
uint8_t phy_read_byte(uint32_t);
uint16_t phy_read_half_word(uint32_t);
uint32_t phy_read_word(uint32_t);
uint64_t phy_read_double_word(uint32_t);

// phy_write* API accept two arguments, write specific length data from the
// second argument `value` to the first argument `address`.
unit phy_write_byte(uint32_t address, uint8_t data);
unit phy_write_half_word(uint32_t address, uint16_t data);
unit phy_write_word(uint32_t address, uint32_t data);
unit phy_write_double_word(uint32_t address, uint64_t data);

unit write_GPR_hook(uint8_t reg, uint64_t value);

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
