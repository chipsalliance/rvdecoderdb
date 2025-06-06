// SD: Stores a 64-bit value from the low bits of register rs2 to memory.
phy_write_double_word(read_GPR(rs1) + sign_extend(imm12), read_GPR(rs2));
PC = PC + 4;
