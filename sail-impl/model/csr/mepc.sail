register Mepc : bits(64)
function reset_mepc() = {
  Mepc = zeros();
}

function clause read_CSR(0x341) = Mepc
function clause write_CSR(0x341, value) = {
  Mepc = [value with 0 = bitzero];
  true
}
