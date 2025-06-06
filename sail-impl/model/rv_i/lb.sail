// LB: Loads an 8-bit value from memory and sign-extends this value to 64 bits before storing it in register rd.
let value : bits(8) = phy_read_byte(read_GPR(rs1) + sign_extend(imm12));
write_GPR(rd, sign_extend(value));
PC = PC + 4;
