function clause read_CSR(0x300) = {
  let z0 : bits(51) = zeros();

  z0 @ mpp @ 0b000 @ mpie @ 0b000 @ mie @ 0b000
}

function clause write_CSR(0x300, value: bits(64)) = {
  mie = [value[3]];
  mpie = [value[7]];
  mpp = value[12..11];
  true
}
