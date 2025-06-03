// SB: Stores an 8-bit value from the low bits of register rs2 to memory.
phy_write_byte(read_GPR(rs1) + sign_extend(imm12), read_GPR(rs2)[7..0]);
tick_pc();
