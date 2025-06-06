function clause read_CSR(0x305) = {
  mtvec_base @ trap_vector_mode_to_bits(mtvec_mode)
}

function clause write_CSR(0x305, value) = {
  mtvec_base = value[64 - 1 .. 2];
  // mode >= 2 is reserved
  mtvec_mode = trap_vector_mode_of_bits(value[1..0]);

  true
}
