let value : bits(32) = imm20 @ 0x000;
let off : bits(64) = sign_extend(value);
write_GPR(rd, off);
PC = PC + 4;
