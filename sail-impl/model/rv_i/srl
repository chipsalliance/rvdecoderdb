let v1 = read_GPR(rs1);
// In RV64I, only the low 6 bits of rs2 are considered for the shift amount.
let v2 = read_GPR(rs2)[5..0];
write_GPR(rd, v1 >> v2);
tick_pc();
