bitfield mcause_state : XLENBITS = {
  INTERRUPT : XLEN - 1,
  EXCEPTION_CODE : XLEN - 2 .. 0,
}
register Mcause : mcause_state

function clause read_CSR(0x342) = {
  Mcause.bits
}

function clause write_CSR(0x342, value : XLENBITS) = {
  Mcause = Mk_mcause_state(value);
  true
}

function reset_mcause() = {
  Mcause = Mk_mcause_state(zeros());
}
