let rs1_val = (read_GPR(rs1))[31..0];
write_GPR(rd, sign_extend(rs1_val << shamtw));
PC = PC + 4;
