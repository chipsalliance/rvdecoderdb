// General Propose Register
// register x0 is not defined to save one register space
register x1 : bits(64)
register x2 : bits(64)
register x3 : bits(64)
register x4 : bits(64)
register x5 : bits(64)
register x6 : bits(64)
register x7 : bits(64)
register x8 : bits(64)
register x9 : bits(64)
register x10 : bits(64)
register x11 : bits(64)
register x12 : bits(64)
register x13 : bits(64)
register x14 : bits(64)
register x15 : bits(64)
register x16 : bits(64)
register x17 : bits(64)
register x18 : bits(64)
register x19 : bits(64)
register x20 : bits(64)
register x21 : bits(64)
register x22 : bits(64)
register x23 : bits(64)
register x24 : bits(64)
register x25 : bits(64)
register x26 : bits(64)
register x27 : bits(64)
register x28 : bits(64)
register x29 : bits(64)
register x30 : bits(64)
register x31 : bits(64)

// Architecture States
register current_privilege : Privilege

register mcause_interrupt : bits(1)
register mcause_exception_code : bits(63)

function reset_mcause() : unit -> unit = {
  mcause_interrupt = zeros();
  mcause_exception_code = zeros();
}

register mepc : bits(64)
function reset_mepc() : unit -> unit = {
  mepc = zeros();
}

register misa_i_enable : bool
function reset_misa_i_enable() : unit -> unit = {
  misa_i_enable = true;
}

register mpp : bits(2)
register mpie : bits(1)
register mie : bits(1)
function reset_machine_states() : unit -> unit = {
  mpp = zeros();
  mpie = zeros();
  mie = zeros();
}

register mtval : bits(64)
function reset_mtval() : unit -> unit = {
  mtval = zeros();
}

register mtvec_base : bits(62)
register mtvec_mode : TrapVectorMode
function reset_mtvec() : unit -> unit = {
  mtvec_base = zeros();
  mtvec_mode = TV_Direct;
}

function reset() : unit -> unit = {
  x1 = zeros();
  x2 = zeros();
  x3 = zeros();
  x4 = zeros();
  x5 = zeros();
  x6 = zeros();
  x7 = zeros();
  x8 = zeros();
  x9 = zeros();
  x10 = zeros();
  x11 = zeros();
  x12 = zeros();
  x13 = zeros();
  x14 = zeros();
  x15 = zeros();
  x16 = zeros();
  x17 = zeros();
  x18 = zeros();
  x19 = zeros();
  x20 = zeros();
  x21 = zeros();
  x22 = zeros();
  x23 = zeros();
  x24 = zeros();
  x25 = zeros();
  x26 = zeros();
  x27 = zeros();
  x28 = zeros();
  x29 = zeros();
  x30 = zeros();
  x31 = zeros();

  reset_mcause();
  reset_mepc();
  reset_misa_i_enable();
  reset_machine_states();
  reset_mtval();
  reset_mtvec();
}
