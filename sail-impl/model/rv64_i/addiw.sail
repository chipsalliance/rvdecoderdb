let result : bits(64) = sign_extend(imm12) + read_GPR(rs1);
write_GPR(rd, sign_extend(result[63..0]));
PC = PC + 4;
