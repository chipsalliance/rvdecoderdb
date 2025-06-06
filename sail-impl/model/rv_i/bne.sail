let rs1_val = read_GPR(rs1);
let rs2_val = read_GPR(rs2);
let taken : bool = rs1_val != rs2_val;
if taken then {
  let t : bits(64) = PC + sign_extend(bimm12 @ 0b0);
  PC = t;
}
