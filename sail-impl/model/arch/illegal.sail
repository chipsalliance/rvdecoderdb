// deal with delegation
let idx = num_of_ExceptionType(E_Illegal_Instr());
mcause_interrupt = 0b0;
mcause_exception_code = zero_extend(exceptionType_to_bits(E_Breakpoint()));

mpie = mie;
mie = 0b0;
mpp = privLevel_to_bits(Machine);
mtval = PC;
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
