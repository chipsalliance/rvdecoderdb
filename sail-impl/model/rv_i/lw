// LW: Loads a 32-bit value from memory and sign-extends this value to 64 bits before storing it in register rd.
let value : bits(32) = phy_read_word(read_GPR(rs1) + sign_extend(imm12));
write_GPR(rd, sign_extend(value));
tick_pc();
