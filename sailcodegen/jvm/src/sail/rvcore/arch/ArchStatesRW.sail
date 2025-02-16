// GPRs
function clause read_GPR(0b00000) = x0
function clause write_GPR(0b00000, v : XLENBITS) = {
	 x0 = v 
}
function clause read_GPR(0b00001) = x1
function clause write_GPR(0b00001, v : XLENBITS) = {
	 x1 = v 
}
function clause read_GPR(0b00010) = x2
function clause write_GPR(0b00010, v : XLENBITS) = {
	 x2 = v 
}
function clause read_GPR(0b00011) = x3
function clause write_GPR(0b00011, v : XLENBITS) = {
	 x3 = v 
}
function clause read_GPR(0b00100) = x4
function clause write_GPR(0b00100, v : XLENBITS) = {
	 x4 = v 
}
function clause read_GPR(0b00101) = x5
function clause write_GPR(0b00101, v : XLENBITS) = {
	 x5 = v 
}
function clause read_GPR(0b00110) = x6
function clause write_GPR(0b00110, v : XLENBITS) = {
	 x6 = v 
}
function clause read_GPR(0b00111) = x7
function clause write_GPR(0b00111, v : XLENBITS) = {
	 x7 = v 
}
function clause read_GPR(0b01000) = x8
function clause write_GPR(0b01000, v : XLENBITS) = {
	 x8 = v 
}
function clause read_GPR(0b01001) = x9
function clause write_GPR(0b01001, v : XLENBITS) = {
	 x9 = v 
}
function clause read_GPR(0b01010) = x10
function clause write_GPR(0b01010, v : XLENBITS) = {
	 x10 = v 
}
function clause read_GPR(0b01011) = x11
function clause write_GPR(0b01011, v : XLENBITS) = {
	 x11 = v 
}
function clause read_GPR(0b01100) = x12
function clause write_GPR(0b01100, v : XLENBITS) = {
	 x12 = v 
}
function clause read_GPR(0b01101) = x13
function clause write_GPR(0b01101, v : XLENBITS) = {
	 x13 = v 
}
function clause read_GPR(0b01110) = x14
function clause write_GPR(0b01110, v : XLENBITS) = {
	 x14 = v 
}
function clause read_GPR(0b01111) = x15
function clause write_GPR(0b01111, v : XLENBITS) = {
	 x15 = v 
}
function clause read_GPR(0b10000) = x16
function clause write_GPR(0b10000, v : XLENBITS) = {
	 x16 = v 
}
function clause read_GPR(0b10001) = x17
function clause write_GPR(0b10001, v : XLENBITS) = {
	 x17 = v 
}
function clause read_GPR(0b10010) = x18
function clause write_GPR(0b10010, v : XLENBITS) = {
	 x18 = v 
}
function clause read_GPR(0b10011) = x19
function clause write_GPR(0b10011, v : XLENBITS) = {
	 x19 = v 
}
function clause read_GPR(0b10100) = x20
function clause write_GPR(0b10100, v : XLENBITS) = {
	 x20 = v 
}
function clause read_GPR(0b10101) = x21
function clause write_GPR(0b10101, v : XLENBITS) = {
	 x21 = v 
}
function clause read_GPR(0b10110) = x22
function clause write_GPR(0b10110, v : XLENBITS) = {
	 x22 = v 
}
function clause read_GPR(0b10111) = x23
function clause write_GPR(0b10111, v : XLENBITS) = {
	 x23 = v 
}
function clause read_GPR(0b11000) = x24
function clause write_GPR(0b11000, v : XLENBITS) = {
	 x24 = v 
}
function clause read_GPR(0b11001) = x25
function clause write_GPR(0b11001, v : XLENBITS) = {
	 x25 = v 
}
function clause read_GPR(0b11010) = x26
function clause write_GPR(0b11010, v : XLENBITS) = {
	 x26 = v 
}
function clause read_GPR(0b11011) = x27
function clause write_GPR(0b11011, v : XLENBITS) = {
	 x27 = v 
}
function clause read_GPR(0b11100) = x28
function clause write_GPR(0b11100, v : XLENBITS) = {
	 x28 = v 
}
function clause read_GPR(0b11101) = x29
function clause write_GPR(0b11101, v : XLENBITS) = {
	 x29 = v 
}
function clause read_GPR(0b11110) = x30
function clause write_GPR(0b11110, v : XLENBITS) = {
	 x30 = v 
}
function clause read_GPR(0b11111) = x31
function clause write_GPR(0b11111, v : XLENBITS) = {
	 x31 = v 
}

// CSRs
function get_mie_MEIE() -> bits(64) = {
	mie.bits
}
function get_mie_SEIE() -> bits(64) = {
	mie.bits
}
function get_mie_MTIE() -> bits(64) = {
	mie.bits
}
function get_mie_STIE() -> bits(64) = {
	mie.bits
}
function get_mie_MSIE() -> bits(64) = {
	mie.bits
}
function get_mie_SSIE() -> bits(64) = {
	mie.bits
}

function clause read_CSR(0x304) = mie.bits
function set_mie_MEIE(v : bits(64)) -> unit = {
	mie = Mk_MIE(v)
}
function set_mie_SEIE(v : bits(64)) -> unit = {
	mie = Mk_MIE(v)
}
function set_mie_MTIE(v : bits(64)) -> unit = {
	mie = Mk_MIE(v)
}
function set_mie_STIE(v : bits(64)) -> unit = {
	mie = Mk_MIE(v)
}
function set_mie_MSIE(v : bits(64)) -> unit = {
	mie = Mk_MIE(v)
}
function set_mie_SSIE(v : bits(64)) -> unit = {
	mie = Mk_MIE(v)
}

function write_mie(v : bits(64)) -> MIE = {
	mie = Mk_MIE(v);
	mie
}
function clause write_CSR(0x304, value) = {
	mie = write_mie(value);
	mie.bits
}
function get_mip_MEIP() -> bits(64) = {
  mip.bits
}
function get_mip_SEIP() -> bits(64) = {
	mip.bits
}
function get_mip_MTIP() -> bits(64) = {
	mip.bits
}
function get_mip_STIP() -> bits(64) = {
	mip.bits
}
function get_mip_MSIP() -> bits(64) = {
	mip.bits
}
function get_mip_SSIP() -> bits(64) = {
	mip.bits
}

function clause read_CSR(0x344) = mip.bits
function set_mip_MEIP(v : bits(64)) -> unit = {
  mip = Mk_MIP(v)
}
function set_mip_SEIP(v : bits(64)) -> unit = {
	mip = Mk_MIP(v)
}
function set_mip_MTIP(v : bits(64)) -> unit = {
	mip = Mk_MIP(v)
}
function set_mip_STIP(v : bits(64)) -> unit = {
	mip = Mk_MIP(v)
}
function set_mip_MSIP(v : bits(64)) -> unit = {
	mip = Mk_MIP(v)
}
function set_mip_SSIP(v : bits(64)) -> unit = {
	mip = Mk_MIP(v)
}

function write_mip(v : bits(64)) -> MIP = {
	mip = Mk_MIP(v);
	mip
}
function clause write_CSR(0x344, value) = {
	mip = write_mip(value);
	mip.bits
}
function get_mideleg_MEID() -> bits(64) = {
	mideleg.bits
}
function get_mideleg_SEID() -> bits(64) = {
	mideleg.bits
}
function get_mideleg_MTID() -> bits(64) = {
	mideleg.bits
}
function get_mideleg_STID() -> bits(64) = {
	mideleg.bits
}
function get_mideleg_MSID() -> bits(64) = {
	mideleg.bits
}
function get_mideleg_SSID() -> bits(64) = {
	mideleg.bits
}

function clause read_CSR(0x303) = mideleg.bits
function set_mideleg_MEID(v : bits(64)) -> unit = {
	mideleg = Mk_MIDELEG(v)
}
function set_mideleg_SEID(v : bits(64)) -> unit = {
	mideleg = Mk_MIDELEG(v)
}
function set_mideleg_MTID(v : bits(64)) -> unit = {
	mideleg = Mk_MIDELEG(v)
}
function set_mideleg_STID(v : bits(64)) -> unit = {
	mideleg = Mk_MIDELEG(v)
}
function set_mideleg_MSID(v : bits(64)) -> unit = {
	mideleg = Mk_MIDELEG(v)
}
function set_mideleg_SSID(v : bits(64)) -> unit = {
	mideleg = Mk_MIDELEG(v)
}

function write_mideleg(v : bits(64)) -> MIDELEG = {
	mideleg = Mk_MIDELEG(v);
	mideleg
}
function clause write_CSR(0x303, value) = {
	mideleg = write_mideleg(value);
	mideleg.bits
}
function get_mstatus_SD() -> bits(64) = {
	mstatus.bits
}
function get_mstatus_TSR() -> bits(64) = {
	mstatus.bits
}
function get_mstatus_TW() -> bits(64) = {
	mstatus.bits
}
function get_mstatus_TVM() -> bits(64) = {
	mstatus.bits
}
function get_mstatus_MXR() -> bits(64) = {
	mstatus.bits
}
function get_mstatus_SUM() -> bits(64) = {
	mstatus.bits
}
function get_mstatus_MPRV() -> bits(64) = {
	mstatus.bits
}
function get_mstatus_XS() -> bits(64) = {
	mstatus.bits
}
function get_mstatus_FS() -> bits(64) = {
	mstatus.bits
}
function get_mstatus_MPP() -> bits(64) = {
	mstatus.bits
}
function get_mstatus_VS() -> bits(64) = {
	mstatus.bits
}
function get_mstatus_SPP() -> bits(64) = {
	mstatus.bits
}
function get_mstatus_MPIE() -> bits(64) = {
	mstatus.bits
}
function get_mstatus_SPIE() -> bits(64) = {
	mstatus.bits
}
function get_mstatus_MIE() -> bits(64) = {
	mstatus.bits
}
function get_mstatus_SIE() -> bits(64) = {
	mstatus.bits
}

function clause read_CSR(0x300) = mstatus.bits
function set_mstatus_SD(v : bits(64)) -> unit = {
	mstatus = Mk_MSTATUS(v)
}
function set_mstatus_TSR(v : bits(64)) -> unit = {
	mstatus = Mk_MSTATUS(v)
}
function set_mstatus_TW(v : bits(64)) -> unit = {
	mstatus = Mk_MSTATUS(v)
}
function set_mstatus_TVM(v : bits(64)) -> unit = {
	mstatus = Mk_MSTATUS(v)
}
function set_mstatus_MXR(v : bits(64)) -> unit = {
	mstatus = Mk_MSTATUS(v)
}
function set_mstatus_SUM(v : bits(64)) -> unit = {
	mstatus = Mk_MSTATUS(v)
}
function set_mstatus_MPRV(v : bits(64)) -> unit = {
	mstatus = Mk_MSTATUS(v)
}
function set_mstatus_XS(v : bits(64)) -> unit = {
	mstatus = Mk_MSTATUS(v)
}
function set_mstatus_FS(v : bits(64)) -> unit = {
	mstatus = Mk_MSTATUS(v)
}
function set_mstatus_MPP(v : bits(64)) -> unit = {
	mstatus = Mk_MSTATUS(v)
}
function set_mstatus_VS(v : bits(64)) -> unit = {
	mstatus = Mk_MSTATUS(v)
}
function set_mstatus_SPP(v : bits(64)) -> unit = {
	mstatus = Mk_MSTATUS(v)
}
function set_mstatus_MPIE(v : bits(64)) -> unit = {
	mstatus = Mk_MSTATUS(v)
}
function set_mstatus_SPIE(v : bits(64)) -> unit = {
	mstatus = Mk_MSTATUS(v)
}
function set_mstatus_MIE(v : bits(64)) -> unit = {
	mstatus = Mk_MSTATUS(v)
}
function set_mstatus_SIE(v : bits(64)) -> unit = {
	mstatus = Mk_MSTATUS(v)
}

function write_mstatus(v : bits(64)) -> MSTATUS = {
	mstatus = Mk_MSTATUS(v);
	mstatus
}
function clause write_CSR(0x300, value) = {
	mstatus = write_mstatus(value);
	mstatus.bits
}
function get_mtvec_Base() -> bits(64) = {
	mtvec.bits
}
function get_mtvec_Mode() -> bits(64) = {
	mtvec.bits
}

function clause read_CSR(0x305) = mtvec.bits
function set_mtvec_Base(v : bits(64)) -> unit = {
	mtvec = Mk_MTVEC(v)
}
function set_mtvec_Mode(v : bits(64)) -> unit = {
	mtvec = Mk_MTVEC(v)
}

function write_mtvec(v : bits(64)) -> MTVEC = {
	mtvec = Mk_MTVEC(v);
	mtvec
}
function clause write_CSR(0x305, value) = {
	mtvec = write_mtvec(value);
	mtvec.bits
}
function get_mcause_IsInterrupt() -> bits(64) = {
	mcause.bits
}
function get_mcause_Cause() -> bits(64) = {
	mcause.bits
}

function clause read_CSR(0x342) = mcause.bits
function set_mcause_IsInterrupt(v : bits(64)) -> unit = {
	mcause = Mk_MCAUSE(v)
}
function set_mcause_Cause(v : bits(64)) -> unit = {
	mcause = Mk_MCAUSE(v)
}

function write_mcause(v : bits(64)) -> MCAUSE = {
	mcause = Mk_MCAUSE(v);
	mcause
}
function clause write_CSR(0x342, value) = {
	mcause = write_mcause(value);
	mcause.bits
}
function get_menvcfg_STCE() -> bits(64) = {
	menvcfg.bits
}
function get_menvcfg_PBMTE() -> bits(64) = {
	menvcfg.bits
}
function get_menvcfg_ADUE() -> bits(64) = {
	menvcfg.bits
}
function get_menvcfg_CDE() -> bits(64) = {
	menvcfg.bits
}
function get_menvcfg_PMM() -> bits(64) = {
	menvcfg.bits
}
function get_menvcfg_CBZE() -> bits(64) = {
	menvcfg.bits
}
function get_menvcfg_CBCFE() -> bits(64) = {
	menvcfg.bits
}
function get_menvcfg_CBIE() -> bits(64) = {
	menvcfg.bits
}
function get_menvcfg_FIOM() -> bits(64) = {
	menvcfg.bits
}

function clause read_CSR(0x30a) = menvcfg.bits
function set_menvcfg_STCE(v : bits(64)) -> unit = {
	menvcfg = Mk_MENVCFG(v)
}
function set_menvcfg_PBMTE(v : bits(64)) -> unit = {
	menvcfg = Mk_MENVCFG(v)
}
function set_menvcfg_ADUE(v : bits(64)) -> unit = {
	menvcfg = Mk_MENVCFG(v)
}
function set_menvcfg_CDE(v : bits(64)) -> unit = {
	menvcfg = Mk_MENVCFG(v)
}
function set_menvcfg_PMM(v : bits(64)) -> unit = {
	menvcfg = Mk_MENVCFG(v)
}
function set_menvcfg_CBZE(v : bits(64)) -> unit = {
	menvcfg = Mk_MENVCFG(v)
}
function set_menvcfg_CBCFE(v : bits(64)) -> unit = {
	menvcfg = Mk_MENVCFG(v)
}
function set_menvcfg_CBIE(v : bits(64)) -> unit = {
	menvcfg = Mk_MENVCFG(v)
}
function set_menvcfg_FIOM(v : bits(64)) -> unit = {
	menvcfg = Mk_MENVCFG(v)
}

function write_menvcfg(v : bits(64)) -> MENVCFG = {
	menvcfg = Mk_MENVCFG(v);
	menvcfg
}
function clause write_CSR(0x30a, value) = {
	menvcfg = write_menvcfg(value);
	menvcfg.bits
}
function get_senvcfg_PMM() -> bits(64) = {
	senvcfg.bits
}
function get_senvcfg_CBZE() -> bits(64) = {
	senvcfg.bits
}
function get_senvcfg_CBCFE() -> bits(64) = {
	senvcfg.bits
}
function get_senvcfg_CBIE() -> bits(64) = {
	senvcfg.bits
}
function get_senvcfg_FIOM() -> bits(64) = {
	senvcfg.bits
}

function clause read_CSR(0x10a) = senvcfg.bits
function set_senvcfg_PMM(v : bits(64)) -> unit = {
	senvcfg = Mk_SENVCFG(v)
}
function set_senvcfg_CBZE(v : bits(64)) -> unit = {
	senvcfg = Mk_SENVCFG(v)
}
function set_senvcfg_CBCFE(v : bits(64)) -> unit = {
	senvcfg = Mk_SENVCFG(v)
}
function set_senvcfg_CBIE(v : bits(64)) -> unit = {
	senvcfg = Mk_SENVCFG(v)
}
function set_senvcfg_FIOM(v : bits(64)) -> unit = {
	senvcfg = Mk_SENVCFG(v)
}

function write_senvcfg(v : bits(64)) -> SENVCFG = {
	senvcfg = Mk_SENVCFG(v);
	senvcfg
}
function clause write_CSR(0x10a, value) = {
	senvcfg = write_senvcfg(value);
	senvcfg.bits
}
function get_satp_MODE() -> bits(64) = {
	satp.bits
}
function get_satp_ASID() -> bits(64) = {
	satp.bits
}
function get_satp_PPN() -> bits(64) = {
	satp.bits
}

function clause read_CSR(0x180) = satp.bits
function set_satp_MODE(v : bits(64)) -> unit = {
	satp = Mk_SATP(v)
}
function set_satp_ASID(v : bits(64)) -> unit = {
	satp = Mk_SATP(v)
}
function set_satp_PPN(v : bits(64)) -> unit = {
	satp = Mk_SATP(v)
}

function write_satp(v : bits(64)) -> SATP = {
	satp = Mk_SATP(v);
	satp
}
function clause write_CSR(0x180, value) = {
	satp = write_satp(value);
	satp.bits
}
function get_misa_MXL() -> bits(64) = {
	misa.bits
}
function get_misa_Z() -> bits(64) = {
	misa.bits
}
function get_misa_Y() -> bits(64) = {
	misa.bits
}
function get_misa_X() -> bits(64) = {
	misa.bits
}
function get_misa_W() -> bits(64) = {
	misa.bits
}
function get_misa_V() -> bits(64) = {
	misa.bits
}
function get_misa_U() -> bits(64) = {
	misa.bits
}
function get_misa_T() -> bits(64) = {
	misa.bits
}
function get_misa_S() -> bits(64) = {
	misa.bits
}
function get_misa_R() -> bits(64) = {
	misa.bits
}
function get_misa_C() -> bits(64) = {
	misa.bits
}

function clause read_CSR(0x301) = misa.bits
function set_misa_MXL(v : bits(64)) -> unit = {
	misa = Mk_MISA(v)
}
function set_misa_Z(v : bits(64)) -> unit = {
	misa = Mk_MISA(v)
}
function set_misa_Y(v : bits(64)) -> unit = {
	misa = Mk_MISA(v)
}
function set_misa_X(v : bits(64)) -> unit = {
	misa = Mk_MISA(v)
}
function set_misa_W(v : bits(64)) -> unit = {
	misa = Mk_MISA(v)
}
function set_misa_V(v : bits(64)) -> unit = {
	misa = Mk_MISA(v)
}
function set_misa_U(v : bits(64)) -> unit = {
	misa = Mk_MISA(v)
}
function set_misa_T(v : bits(64)) -> unit = {
	misa = Mk_MISA(v)
}
function set_misa_S(v : bits(64)) -> unit = {
	misa = Mk_MISA(v)
}
function set_misa_R(v : bits(64)) -> unit = {
	misa = Mk_MISA(v)
}
function set_misa_C(v : bits(64)) -> unit = {
	misa = Mk_MISA(v)
}

function write_misa(v : bits(64)) -> MISA = {
	misa = Mk_MISA(v);
	misa
}
function clause write_CSR(0x301, value) = {
	misa = write_misa(value);
	misa.bits
}
function get_mtval_mtval() -> bits(64) = {
	mtval.bits
}

function clause read_CSR(0x343) = mtval.bits
function set_mtval_mtval(v : bits(64)) -> unit = {
	mtval = Mk_MTVAL(v)
}

function write_mtval(v : bits(64)) -> MTVAL = {
	mtval = Mk_MTVAL(v);
	mtval
}
function clause write_CSR(0x343, value) = {
	mtval = write_mtval(value);
	mtval.bits
}
function get_mepc_mepc() -> bits(64) = {
	mepc.bits
}

function clause read_CSR(0x341) = mepc.bits
function set_mepc_mepc(v : bits(64)) -> unit = {
	mepc = Mk_MEPC(v)
}

function write_mepc(v : bits(64)) -> MEPC = {
	mepc = Mk_MEPC(v);
	mepc
}
function clause write_CSR(0x341, value) = {
	mepc = write_mepc(value);
	mepc.bits
}
function get_stvec_Base() -> bits(64) = {
	stvec.bits
}
function get_stvec_Mode() -> bits(64) = {
	stvec.bits
}

function clause read_CSR(0x105) = stvec.bits
function set_stvec_Base(v : bits(64)) -> unit = {
	stvec = Mk_STVEC(v)
}
function set_stvec_Mode(v : bits(64)) -> unit = {
	stvec = Mk_STVEC(v)
}

function write_stvec(v : bits(64)) -> STVEC = {
	stvec = Mk_STVEC(v);
	stvec
}
function clause write_CSR(0x105, value) = {
	stvec = write_stvec(value);
	stvec.bits
}
function get_sepc_sepc() -> bits(64) = {
	sepc.bits
}

function clause read_CSR(0x141) = sepc.bits
function set_sepc_sepc(v : bits(64)) -> unit = {
	sepc = Mk_SEPC(v)
}

function write_sepc(v : bits(64)) -> SEPC = {
	sepc = Mk_SEPC(v);
	sepc
}
function clause write_CSR(0x141, value) = {
	sepc = write_sepc(value);
	sepc.bits
}
function get_scause_IsInterrupt() -> bits(64) = {
	scause.bits
}
function get_scause_Cause() -> bits(64) = {
	scause.bits
}

function clause read_CSR(0x142) = scause.bits
function set_scause_IsInterrupt(v : bits(64)) -> unit = {
	scause = Mk_SCAUSE(v)
}
function set_scause_Cause(v : bits(64)) -> unit = {
	scause = Mk_SCAUSE(v)
}

function write_scause(v : bits(64)) -> SCAUSE = {
	scause = Mk_SCAUSE(v);
	scause
}
function clause write_CSR(0x142, value) = {
	scause = write_scause(value);
	scause.bits
}
function get_stval_stval() -> bits(64) = {
	stval.bits
}

function clause read_CSR(0x143) = stval.bits
function set_stval_stval(v : bits(64)) -> unit = {
	stval = Mk_STVAL(v)
}

function write_stval(v : bits(64)) -> STVAL = {
	stval = Mk_STVAL(v);
	stval
}
function clause write_CSR(0x143, value) = {
	stval = write_stval(value);
	stval.bits
}
function get_medeleg_MEDELEG() -> bits(64) = {
	medeleg.bits
}

function clause read_CSR(0x302) = medeleg.bits
function set_medeleg_MEDELEG(v : bits(64)) -> unit = {
	medeleg = Mk_MEDELEG(v)
}

function write_medeleg(v : bits(64)) -> MEDELEG = {
	medeleg = Mk_MEDELEG(v);
	medeleg
}
function clause write_CSR(0x302, value) = {
	medeleg = write_medeleg(value);
	medeleg.bits
}
