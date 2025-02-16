// GPRs
register x0 : XLENBITS
register x1 : XLENBITS
register x2 : XLENBITS
register x3 : XLENBITS
register x4 : XLENBITS
register x5 : XLENBITS
register x6 : XLENBITS
register x7 : XLENBITS
register x8 : XLENBITS
register x9 : XLENBITS
register x10 : XLENBITS
register x11 : XLENBITS
register x12 : XLENBITS
register x13 : XLENBITS
register x14 : XLENBITS
register x15 : XLENBITS
register x16 : XLENBITS
register x17 : XLENBITS
register x18 : XLENBITS
register x19 : XLENBITS
register x20 : XLENBITS
register x21 : XLENBITS
register x22 : XLENBITS
register x23 : XLENBITS
register x24 : XLENBITS
register x25 : XLENBITS
register x26 : XLENBITS
register x27 : XLENBITS
register x28 : XLENBITS
register x29 : XLENBITS
register x30 : XLENBITS
register x31 : XLENBITS
// CSRs
register mie				: MIE
register mip				: MIP
register mideleg				: MIDELEG
register mstatus				: MSTATUS
register mtvec				: MTVEC
register mcause				: MCAUSE
register menvcfg				: MENVCFG
register senvcfg				: SENVCFG
register satp				: SATP
register misa				: MISA
register mtval				: MTVAL
register mepc				: MEPC
register stvec				: STVEC
register sepc				: SEPC
register scause				: SCAUSE
register stval				: STVAL
register medeleg				: MEDELEG

// PC
register PC : XLENBITS
// Privilege
register cur_privilege : Privilege
