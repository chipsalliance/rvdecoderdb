let rs1_val = read_GPR(rs1);
let immext : bits(64) = sign_extend(imm12);
write_GPR(rd, rs1_val ^ immext);
PC = PC + 4;
