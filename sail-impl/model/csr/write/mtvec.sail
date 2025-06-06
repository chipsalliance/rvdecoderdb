mtvec_base = value[64 - 1 .. 2];
// mode >= 2 is reserved
mtvec_mode = trap_vector_mode_of_bits(value[1..0]);

true
