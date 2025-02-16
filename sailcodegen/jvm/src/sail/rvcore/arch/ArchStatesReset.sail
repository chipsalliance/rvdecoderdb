// GPRs
val get_resetval_x0 = pure "get_resetval_x0" : unit -> bits(64)
val get_resetval_x1 = pure "get_resetval_x1" : unit -> bits(64)
val get_resetval_x2 = pure "get_resetval_x2" : unit -> bits(64)
val get_resetval_x3 = pure "get_resetval_x3" : unit -> bits(64)
val get_resetval_x4 = pure "get_resetval_x4" : unit -> bits(64)
val get_resetval_x5 = pure "get_resetval_x5" : unit -> bits(64)
val get_resetval_x6 = pure "get_resetval_x6" : unit -> bits(64)
val get_resetval_x7 = pure "get_resetval_x7" : unit -> bits(64)
val get_resetval_x8 = pure "get_resetval_x8" : unit -> bits(64)
val get_resetval_x9 = pure "get_resetval_x9" : unit -> bits(64)
val get_resetval_x10 = pure "get_resetval_x10" : unit -> bits(64)
val get_resetval_x11 = pure "get_resetval_x11" : unit -> bits(64)
val get_resetval_x12 = pure "get_resetval_x12" : unit -> bits(64)
val get_resetval_x13 = pure "get_resetval_x13" : unit -> bits(64)
val get_resetval_x14 = pure "get_resetval_x14" : unit -> bits(64)
val get_resetval_x15 = pure "get_resetval_x15" : unit -> bits(64)
val get_resetval_x16 = pure "get_resetval_x16" : unit -> bits(64)
val get_resetval_x17 = pure "get_resetval_x17" : unit -> bits(64)
val get_resetval_x18 = pure "get_resetval_x18" : unit -> bits(64)
val get_resetval_x19 = pure "get_resetval_x19" : unit -> bits(64)
val get_resetval_x20 = pure "get_resetval_x20" : unit -> bits(64)
val get_resetval_x21 = pure "get_resetval_x21" : unit -> bits(64)
val get_resetval_x22 = pure "get_resetval_x22" : unit -> bits(64)
val get_resetval_x23 = pure "get_resetval_x23" : unit -> bits(64)
val get_resetval_x24 = pure "get_resetval_x24" : unit -> bits(64)
val get_resetval_x25 = pure "get_resetval_x25" : unit -> bits(64)
val get_resetval_x26 = pure "get_resetval_x26" : unit -> bits(64)
val get_resetval_x27 = pure "get_resetval_x27" : unit -> bits(64)
val get_resetval_x28 = pure "get_resetval_x28" : unit -> bits(64)
val get_resetval_x29 = pure "get_resetval_x29" : unit -> bits(64)
val get_resetval_x30 = pure "get_resetval_x30" : unit -> bits(64)
val get_resetval_x31 = pure "get_resetval_x31" : unit -> bits(64)
function reset_x0() : unit -> unit = { x0 = get_resetval_x0(); }
function reset_x1() : unit -> unit = { x1 = get_resetval_x1(); }
function reset_x2() : unit -> unit = { x2 = get_resetval_x2(); }
function reset_x3() : unit -> unit = { x3 = get_resetval_x3(); }
function reset_x4() : unit -> unit = { x4 = get_resetval_x4(); }
function reset_x5() : unit -> unit = { x5 = get_resetval_x5(); }
function reset_x6() : unit -> unit = { x6 = get_resetval_x6(); }
function reset_x7() : unit -> unit = { x7 = get_resetval_x7(); }
function reset_x8() : unit -> unit = { x8 = get_resetval_x8(); }
function reset_x9() : unit -> unit = { x9 = get_resetval_x9(); }
function reset_x10() : unit -> unit = { x10 = get_resetval_x10(); }
function reset_x11() : unit -> unit = { x11 = get_resetval_x11(); }
function reset_x12() : unit -> unit = { x12 = get_resetval_x12(); }
function reset_x13() : unit -> unit = { x13 = get_resetval_x13(); }
function reset_x14() : unit -> unit = { x14 = get_resetval_x14(); }
function reset_x15() : unit -> unit = { x15 = get_resetval_x15(); }
function reset_x16() : unit -> unit = { x16 = get_resetval_x16(); }
function reset_x17() : unit -> unit = { x17 = get_resetval_x17(); }
function reset_x18() : unit -> unit = { x18 = get_resetval_x18(); }
function reset_x19() : unit -> unit = { x19 = get_resetval_x19(); }
function reset_x20() : unit -> unit = { x20 = get_resetval_x20(); }
function reset_x21() : unit -> unit = { x21 = get_resetval_x21(); }
function reset_x22() : unit -> unit = { x22 = get_resetval_x22(); }
function reset_x23() : unit -> unit = { x23 = get_resetval_x23(); }
function reset_x24() : unit -> unit = { x24 = get_resetval_x24(); }
function reset_x25() : unit -> unit = { x25 = get_resetval_x25(); }
function reset_x26() : unit -> unit = { x26 = get_resetval_x26(); }
function reset_x27() : unit -> unit = { x27 = get_resetval_x27(); }
function reset_x28() : unit -> unit = { x28 = get_resetval_x28(); }
function reset_x29() : unit -> unit = { x29 = get_resetval_x29(); }
function reset_x30() : unit -> unit = { x30 = get_resetval_x30(); }
function reset_x31() : unit -> unit = { x31 = get_resetval_x31(); }
// CSRs
val get_resetval_mie = pure "get_resetval_mie" : unit -> bits(64)
val get_resetval_mip = pure "get_resetval_mip" : unit -> bits(64)
val get_resetval_mideleg = pure "get_resetval_mideleg" : unit -> bits(64)
val get_resetval_mstatus = pure "get_resetval_mstatus" : unit -> bits(64)
val get_resetval_mtvec = pure "get_resetval_mtvec" : unit -> bits(64)
val get_resetval_mcause = pure "get_resetval_mcause" : unit -> bits(64)
val get_resetval_menvcfg = pure "get_resetval_menvcfg" : unit -> bits(64)
val get_resetval_senvcfg = pure "get_resetval_senvcfg" : unit -> bits(64)
val get_resetval_satp = pure "get_resetval_satp" : unit -> bits(64)
val get_resetval_misa = pure "get_resetval_misa" : unit -> bits(64)
val get_resetval_mtval = pure "get_resetval_mtval" : unit -> bits(64)
val get_resetval_mepc = pure "get_resetval_mepc" : unit -> bits(64)
val get_resetval_stvec = pure "get_resetval_stvec" : unit -> bits(64)
val get_resetval_sepc = pure "get_resetval_sepc" : unit -> bits(64)
val get_resetval_scause = pure "get_resetval_scause" : unit -> bits(64)
val get_resetval_stval = pure "get_resetval_stval" : unit -> bits(64)
val get_resetval_medeleg = pure "get_resetval_medeleg" : unit -> bits(64)
function reset_mie() : unit -> unit = { mie = Mk_MIE(get_resetval_mie()) }
function reset_mip() : unit -> unit = { mip = Mk_MIP(get_resetval_mip()) }
function reset_mideleg() : unit -> unit = { mideleg = Mk_MIDELEG(get_resetval_mideleg()) }
function reset_mstatus() : unit -> unit = { mstatus = Mk_MSTATUS(get_resetval_mstatus()) }
function reset_mtvec() : unit -> unit = { mtvec = Mk_MTVEC(get_resetval_mtvec()) }
function reset_mcause() : unit -> unit = { mcause = Mk_MCAUSE(get_resetval_mcause()) }
function reset_menvcfg() : unit -> unit = { menvcfg = Mk_MENVCFG(get_resetval_menvcfg()) }
function reset_senvcfg() : unit -> unit = { senvcfg = Mk_SENVCFG(get_resetval_senvcfg()) }
function reset_satp() : unit -> unit = { satp = Mk_SATP(get_resetval_satp()) }
function reset_misa() : unit -> unit = { misa = Mk_MISA(get_resetval_misa()) }
function reset_mtval() : unit -> unit = { mtval = Mk_MTVAL(get_resetval_mtval()) }
function reset_mepc() : unit -> unit = { mepc = Mk_MEPC(get_resetval_mepc()) }
function reset_stvec() : unit -> unit = { stvec = Mk_STVEC(get_resetval_stvec()) }
function reset_sepc() : unit -> unit = { sepc = Mk_SEPC(get_resetval_sepc()) }
function reset_scause() : unit -> unit = { scause = Mk_SCAUSE(get_resetval_scause()) }
function reset_stval() : unit -> unit = { stval = Mk_STVAL(get_resetval_stval()) }
function reset_medeleg() : unit -> unit = { medeleg = Mk_MEDELEG(get_resetval_medeleg()) }
function reset() : unit -> unit = {
	reset_x0();
	reset_x1();
	reset_x2();
	reset_x3();
	reset_x4();
	reset_x5();
	reset_x6();
	reset_x7();
	reset_x8();
	reset_x9();
	reset_x10();
	reset_x11();
	reset_x12();
	reset_x13();
	reset_x14();
	reset_x15();
	reset_x16();
	reset_x17();
	reset_x18();
	reset_x19();
	reset_x20();
	reset_x21();
	reset_x22();
	reset_x23();
	reset_x24();
	reset_x25();
	reset_x26();
	reset_x27();
	reset_x28();
	reset_x29();
	reset_x30();
	reset_x31();
	reset_mie();
	reset_mip();
	reset_mideleg();
	reset_mstatus();
	reset_mtvec();
	reset_mcause();
	reset_menvcfg();
	reset_senvcfg();
	reset_satp();
	reset_misa();
	reset_mtval();
	reset_mepc();
	reset_stvec();
	reset_sepc();
	reset_scause();
	reset_stval();
	reset_medeleg();
}