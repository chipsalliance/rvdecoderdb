let e : ExceptionType = match(cur_privilege) {
  Machine     => E_M_EnvCall(),
  Supervisor  => E_S_EnvCall(),
  User        => E_U_EnvCall()
};

// deal with delegation
let idx = num_of_ExceptionType(e);
Mcause[INTERRUPT] = 0b0;
Mcause[EXCEPTION_CODE] = zero_extend(exceptionType_to_bits(e));

Mstatus[MPIE] = Mstatus[MIE];
Mstatus[MIE] = 0b0;
Mstatus[MPP] = privLevel_to_bits(cur_privilege);
Mtval = zeros();
Mepc = PC;

let base : XLENBITS = Mtvec[BASE] @ 0b00;
let t : XLENBITS = match (trapVectorMode_of_bits(Mtvec[MODE])) {
  TV_Direct =>  base,
  TV_Vector =>  if Mcause[INTERRUPT] == 0b1
                then (base + (zero_extend(Mcause[EXCEPTION_CODE] << 2)))
                else base,
  TV_Reserved => internal_error("Invalid mtvec mode")
};
set_pc(t);
