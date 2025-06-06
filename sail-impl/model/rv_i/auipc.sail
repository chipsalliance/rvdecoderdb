let value : bits(32) = imm20 @ 0x000;
let off : bits(64) = sign_extend(value);
let ret : bits(64) = PC + off;
write_GPR(rd, ret);
PC = PC + 4;
