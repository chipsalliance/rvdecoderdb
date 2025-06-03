bitfield mstatus_state : bits(4) = {
  MPP : 3..2,
  MPIE : 1,
  MIE : 0,
}

register Mstatus : mstatus_state

function clause read_CSR(0x300) = {
  let z0 : bits(51) = zeros();

  z0 @ Mstatus[MPP] @ 0b000 @ Mstatus[MPIE] @ 0b000 @ Mstatus[MIE] @ 0b000
}

function clause write_CSR(0x300, value: XLENBITS) = {
  Mstatus[MIE] = [value[3]];
  Mstatus[MPIE] = [value[7]];
  Mstatus[MPP] = value[12..11];
  true
}

function reset_mstatus() = {
  Mstatus = Mk_mstatus_state(zeros());
}
