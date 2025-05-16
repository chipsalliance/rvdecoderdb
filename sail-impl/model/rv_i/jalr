let rs1_val = read_GPR(rs1);
let t : XLENBITS = rs1_val + sign_extend(imm12);
let ret : XLENBITS = PC + 4;
set_pc([t with 0 = bitzero]);
write_GPR(rd, ret);
