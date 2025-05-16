let rs1_val = read_GPR(rs1);
let rs2_val = read_GPR(rs2)[5..0];
write_GPR(rd, shift_right_arith64(rs1_val, rs2_val));
tick_pc();
