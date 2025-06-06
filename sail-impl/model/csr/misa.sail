function clause read_CSR(0x301) = {
  // MXL @ 9 x 4 zero bit @ extension
  let read_only : bits(36) = zeros();
  let z_to_i : bits(17) = zeros();
  let misa_e : bits(1) = bool_to_bits(not(misa_i_enable));
  0b10 @ read_only @ z_to_i @ bool_to_bits(misa_i_enable) @ 0b000 @ misa_e @ 0x0
}

function clause write_CSR(0x301, value: bits(64)) = {
  misa_i_enable = bit_to_bool(value[8]);
  true
}
