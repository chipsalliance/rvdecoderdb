let t : bits(64) = PC + sign_extend(jimm20);
write_GPR(0b00001, t);
PC = t;
