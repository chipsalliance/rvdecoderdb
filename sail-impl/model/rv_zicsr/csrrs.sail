// For both CSRRS and CSRRC, if rs1=x0, then the instruction will not write to
// the CSR at all, and so shall not cause any of the side effects that might
// otherwise occur on a CSR write, nor raise illegal instruction exceptions on
// accesses to read-only CSRs.
//
// Both CSRRS and CSRRC always read the addressed CSR and cause any read side
// effects regardless of rs1 and rd fields.

let csr_value: bits(64) = zero_extend(read_CSR(csr));
if rs1 != 0b00000 then {
  write_GPR(rd, csr_value);
  let bit_mask: bits(64) = read_GPR(rs1);
  let result: bits(64) = csr_value | bit_mask;
  let _ = write_CSR(csr, result);
};
PC = PC + 4;
