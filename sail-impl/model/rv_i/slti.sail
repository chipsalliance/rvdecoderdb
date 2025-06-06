let rs1_val = read_GPR(rs1);
let immext : bits(64) = sign_extend(imm12);
write_GPR(rd, zero_extend(bool_to_bits(rs1_val <_s immext)));
PC = PC + 4;
