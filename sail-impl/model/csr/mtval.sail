register Mtval : bits(64)

function reset_mtval() = {
  Mtval = zeros();
}

function clause read_CSR(0x343) = Mtval

function clause write_CSR(0x343, value: XLENBITS) = {
  Mtval = [value with 0 = bitzero];
  true
}
