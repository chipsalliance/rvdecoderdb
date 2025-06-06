// According to the spec:
//
// > If rd=x0, then the instruction shall not read the CSR and shall not cause
// > any of the side effects that might occur on a CSR read.
//
if rd != 0b00000 then {
  let old_value: bits(64) = zero_extend(read_CSR(csr));
  write_GPR(rd, old_value);
  let init_value: bits(64) = read_GPR(rs1);
  let _ = write_CSR(csr, init_value);
};
PC = PC + 4;
