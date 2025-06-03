bitfield misa_state : bits(1) = {
  I : 0
}

// following Sail convention, we use upper case for bitfield register here
register MISA : misa_state

function clause read_CSR(0x301) = {
  // MXL @ 9 x 4 zero bit @ extension
  let read_only : bits(36) = zeros();
  let z_to_i : bits(17) = zeros();
  let misa_e : bits(1) = ~(MISA[I]);
  0b10 @ read_only @ z_to_i @ MISA[I] @ 0b000 @ misa_e @ 0x0
}

function clause write_CSR(0x301, value: XLENBITS) = {
  MISA[I] = [value[8]];
  true
}

function reset_misa() = {
  MISA = [Mk_misa_state(zeros()) with I = 0b1];
}
