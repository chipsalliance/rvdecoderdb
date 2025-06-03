bitfield mtvec_state : bits(XLEN) = {
  BASE : XLEN - 1 .. 2,
  MODE : 1 .. 0,
}
register Mtvec : mtvec_state

function clause read_CSR(0x305) = Mtvec.bits

function clause write_CSR(0x305, value) = {
  Mtvec[BASE] = value[XLEN - 1 .. 2];
  // mode >= 2 is reserved
  Mtvec[MODE] = 0b0 @ [value[0]];

  true
}

function reset_mtvec() = {
  Mtvec = Mk_mtvec_state(zeros());
}
