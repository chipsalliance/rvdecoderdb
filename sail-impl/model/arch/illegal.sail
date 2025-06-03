// deal with delegation
let idx = num_of_ExceptionType(E_Illegal_Instr());
Mcause[INTERRUPT] = 0b0;
Mcause[EXCEPTION_CODE] = zero_extend(exceptionType_to_bits(E_Breakpoint()));

Mstatus[MPIE] = Mstatus[MIE];
Mstatus[MIE] = 0b0;
Mstatus[MPP] = privLevel_to_bits(Machine);
Mtval = PC;
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
