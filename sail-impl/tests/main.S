    .globl _start

do_tohost:
    addi    sp,sp,-32
    sd      ra,24(sp)
    sd      s0,16(sp)
    addi    s0,sp,32
    sd      a0,-24(s0)
    lui     a5,%hi(tohost)
    ld      a4,-24(s0)
    sd      a4,%lo(tohost)(a5)
    nop
    ld      ra,24(sp)
    ld      s0,16(sp)
    addi    sp,sp,32
    jr      ra

_start:
    li x1, 0
    li x2, 0
    li x3, 0
    li x4, 0
    li x5, 0
    li x6, 0
    li x7, 0
    li x8, 0
    li x9, 0
    li x10, 0
    li x11, 0
    li x12, 0
    li x13, 0
    li x14, 0
    li x15, 0
    li x16, 0
    li x17, 0
    li x18, 0
    li x19, 0
    li x20, 0
    li x21, 0
    li x22, 0
    li x23, 0
    li x24, 0
    li x25, 0
    li x26, 0
    li x27, 0
    li x28, 0
    li x29, 0
    li x30, 0
    li x31, 0

    la sp, __stacktop

    // no ra to save
    call test

    // exit
    li a0, 1
    call do_tohost

    .p2align 2

