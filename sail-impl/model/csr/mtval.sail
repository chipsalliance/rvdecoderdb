function clause read_CSR(0x343) = mtval

function clause write_CSR(0x343, value: bits(64)) = {
  // must be 4 aligned
  mtval = [value with 0 = bitzero, 1 = bitzero];
  true
}
