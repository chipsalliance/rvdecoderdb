function clause read_CSR(0x341) = mepc
function clause write_CSR(0x341, value) = {
  mepc = [value with 0 = bitzero];
  true
}
