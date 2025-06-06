// SH: Stores a 16-bit value from the low bits of register rs2 to memory.
phy_write_half_word(read_GPR(rs1) + sign_extend(imm12), read_GPR(rs2)[15..0]);
PC = PC + 4;
