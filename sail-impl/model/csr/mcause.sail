function clause read_CSR(0x342) = {
  mcause_interrupt @ mcause_exception_code
}

function clause write_CSR(0x342, value : bits(64)) = {
  mcause_interrupt = [value[63]];
  mcause_exception_code = value[62..0];

  true
}
