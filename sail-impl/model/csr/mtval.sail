register Mtval : bits(64)

function clause read_CSR(0x343) = Mtval

function clause write_CSR(0x343, value: bits(64)) = {
  Mtval = [value with 0 = bitzero];
  true
}
