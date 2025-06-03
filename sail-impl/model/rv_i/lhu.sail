// LHU: Loads a 16-bit value from memory and zero-extends this value to 64 bits before storing it in register rd.
let value : bits(16) = phy_read_half_word(read_GPR(rs1) + sign_extend(imm12));
write_GPR(rd, zero_extend(value));
tick_pc();
