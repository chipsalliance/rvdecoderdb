bitfield mcause_state : bits(64) = {
  INTERRUPT : 64 - 1,
  EXCEPTION_CODE : 64 - 2 .. 0,
}
register Mcause : mcause_state

function clause read_CSR(0x342) = {
  Mcause.bits
}

function clause write_CSR(0x342, value : bits(64)) = {
  Mcause = Mk_mcause_state(value);
  true
}
