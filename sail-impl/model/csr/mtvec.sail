bitfield mtvec_state : bits(64) = {
  BASE : 64 - 1 .. 2,
  MODE : 1 .. 0,
}
register Mtvec : mtvec_state

function clause read_CSR(0x305) = Mtvec.bits

function clause write_CSR(0x305, value) = {
  Mtvec[BASE] = value[64 - 1 .. 2];
  // mode >= 2 is reserved
  Mtvec[MODE] = 0b0 @ [value[0]];

  true
}
