// LD: Loads a 64-bit value from memory into register rd.
let value : XLENBITS = phy_read_double_word(read_GPR(rs1) + sign_extend(imm12));
write_GPR(rd, zero_extend(value));
tick_pc();
