let e : ExceptionType = match(current_privilege) {
  Machine     => E_M_EnvCall(),
  Supervisor  => E_S_EnvCall(),
  User        => E_U_EnvCall()
};

// deal with delegation
let idx = num_of_ExceptionType(e);
mcause_interrupt = 0b0;
mcause_exception_code = zero_extend(exceptionType_to_bits(e));

mpie = mie;
mie = 0b0;
mpp = privLevel_to_bits(current_privilege);
mtval = zeros();
mepc = PC;

let base : bits(64) = mtvec_base @ 0b00;
let t : bits(64) = match (mtvec_mode) {
  TV_Direct =>  base,
  TV_Vector =>  if mcause_interrupt == 0b1
                then (base + (zero_extend(mcause_exception_code << 2)))
                else base,
  TV_Reserved => internal_error("Invalid mtvec mode")
};
PC = t;
