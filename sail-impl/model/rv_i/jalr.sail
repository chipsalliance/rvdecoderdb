let rs1_val = read_GPR(rs1);
let t : bits(64) = rs1_val + sign_extend(imm12);
let ret : bits(64) = PC + 4;
PC = [t with 0 = bitzero];
write_GPR(rd, ret);
