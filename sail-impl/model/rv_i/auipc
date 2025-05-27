let value : bits(32) = imm20 @ 0x000;
let off : XLENBITS = sign_extend(value);
let ret : XLENBITS = PC + off;
write_GPR(rd, ret);
tick_pc();
