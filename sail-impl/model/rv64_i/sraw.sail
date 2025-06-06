let rs1_val = (read_GPR(rs1))[31..0];
let rs2_val = read_GPR(rs2)[4..0];
write_GPR(rd, sign_extend(shift_right_arith32(rs1_val, rs2_val)));
PC = PC + 4;
