// For CSRRSI and CSRRCI, if the uimm[4:0] field is zero, then these
// instructions will not write to the CSR, and shall not cause any of the side
// effects that might otherwise occur on a CSR write, nor raise illegal
// instruction exceptions on accesses to read-only CSRs.
//
// Both CSRRSI and CSRRCI will always read the CSR and cause any read side
// effects regardless of rd and rs1 fields.

let csr_value: bits(64) = zero_extend(read_CSR(csr));
if zimm != 0b00000 then {
  write_GPR(rd, csr_value);
  let value: bits(64) = zero_extend(zimm);
  let result: bits(64) = csr_value & ~(value);
  let _ = write_CSR(csr, result);
};
PC = PC + 4;
