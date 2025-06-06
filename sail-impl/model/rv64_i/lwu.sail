let value : bits(32) = phy_read_word(read_GPR(rs1) + sign_extend(imm12));
write_GPR(rd, zero_extend(value));
PC = PC + 4;
