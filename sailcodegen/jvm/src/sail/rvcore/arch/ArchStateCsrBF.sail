bitfield MIE : bits(64) = {
	MEIE : 11,
	SEIE : 9,
	MTIE : 7,
	STIE : 5,
	MSIE : 3,
	SSIE : 1
}

bitfield MIP : bits(64) = {
	MEIP : 11,
	SEIP : 9,
	MTIP : 7,
	STIP : 5,
	MSIP : 3,
	SSIP : 1
}

bitfield MIDELEG : bits(64) = {
	MEID : 11,
	SEID : 9,
	MTID : 7,
	STID : 5,
	MSID : 3,
	SSID : 1
}

bitfield MSTATUS : bits(64) = {
	SD : 64 - 1,
	TSR : 22,
	TW : 21,
	TVM : 20,
	MXR : 19,
	SUM : 18,
	MPRV : 17,
	XS : 16..15,
	FS : 14..13,
	MPP : 12..11,
	VS : 10..9,
	SPP : 8,
	MPIE : 7,
	SPIE : 5,
	MIE : 3,
	SIE : 1
}

bitfield MTVEC : bits(64) = {
	Base : 64 - 1..2,
	Mode : 1..0
}

bitfield MCAUSE : bits(64) = {
	IsInterrupt : 64 - 1,
	Cause : 64 - 2..0
}

bitfield MENVCFG : bits(64) = {
	STCE : 63,
	PBMTE : 62,
	ADUE : 61,
	CDE : 60,
	PMM : 33..32,
	CBZE : 7,
	CBCFE : 6,
	CBIE : 5..4,
	FIOM : 0
}

bitfield SENVCFG : bits(64) = {
	PMM : 33..32,
	CBZE : 7,
	CBCFE : 6,
	CBIE : 5..4,
	FIOM : 0
}

bitfield SATP : bits(64) = {
	MODE : 31,
	ASID : 30..22,
	PPN : 21..0
}

bitfield MISA : bits(64) = {
	MXL : (64 - 1)..(64 - 2),
	Z : 25,
	Y : 24,
	X : 23,
	W : 22,
	V : 21,
	U : 20,
	T : 19,
	S : 18,
	R : 17,
	C : 2
}

bitfield MTVAL : bits(64) = {
	mtval : 64 - 1..0
}

bitfield MEPC : bits(64) = {
	mepc : 64 - 1..0
}

bitfield STVEC : bits(64) = {
	Base : 64 - 1..2,
	Mode : 1..0
}

bitfield SEPC : bits(64) = {
	sepc : 64 - 1..0
}

bitfield SCAUSE : bits(64) = {
	IsInterrupt : 64 - 1,
	Cause : 64 - 2..0
}

bitfield STVAL : bits(64) = {
	stval : 64 - 1..0
}

bitfield MEDELEG : bits(64) = {
	MEDELEG : 64 - 1..0
}

