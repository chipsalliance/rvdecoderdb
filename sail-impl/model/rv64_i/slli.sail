let rs1_val = read_GPR(rs1);
write_GPR(rd, rs1_val << shamtd);
PC = PC + 4;
