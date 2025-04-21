// model-internal exceptions 

union exception = {
  Error_not_implemented : string,
  Error_internal_error  : unit
}

val not_implemented : forall ('a : Type). string -> 'a
function not_implemented message = throw(Error_not_implemented(message))

val internal_error : forall ('a : Type). (string) -> 'a
function internal_error(s) = {
    assert (false, s);
    throw Error_internal_error()
}

register nextPC : XLENBITS

// GPR
type regidx  = bits(5)

val read_GPR : regidx -> XLENBITS
scattered function read_GPR

val write_GPR : (regidx, XLENBITS) -> unit
scattered function write_GPR

type cregidx = bits(3)

val creg2reg_idx : cregidx -> regidx
function creg2reg_idx(creg) = 0b01 @ creg

// CSR
type csreg   = bits(12)

val is_CSR_defined : (csreg) -> bool
scattered function is_CSR_defined

val read_CSR : csreg -> XLENBITS
scattered function read_CSR

val write_CSR : (csreg, XLENBITS) -> XLENBITS
scattered function write_CSR

type priv_level = bits(2)
enum Privilege  = {User, Supervisor, Machine}

type ext_exc_type = unit

union ExceptionType = {
 E_Fetch_Addr_Align   : unit,
 E_Fetch_Access_Fault : unit,
 E_Illegal_Instr      : unit,
 E_Breakpoint         : unit,
 E_Load_Addr_Align    : unit,
 E_Load_Access_Fault  : unit,
 E_SAMO_Addr_Align    : unit,
 E_SAMO_Access_Fault  : unit,
 E_U_EnvCall          : unit,
 E_S_EnvCall          : unit,
 E_Reserved_10        : unit,
 E_M_EnvCall          : unit,
 E_Fetch_Page_Fault   : unit,
 E_Load_Page_Fault    : unit,
 E_Reserved_14        : unit,
 E_SAMO_Page_Fault    : unit,

 /* extensions */
 E_Extension          : ext_exc_type
}

val num_of_ext_exc_type : ext_exc_type -> {'n, (0 <= 'n < XLEN). int('n)}
function num_of_ext_exc_type(e) = 24

val num_of_ExceptionType : ExceptionType -> {'n, (0 <= 'n < XLEN). int('n)}
function num_of_ExceptionType(e) =
  match (e) {
    E_Fetch_Addr_Align()   => 0,
    E_Fetch_Access_Fault() => 1,
    E_Illegal_Instr()      => 2,
    E_Breakpoint()         => 3,
    E_Load_Addr_Align()    => 4,
    E_Load_Access_Fault()  => 5,
    E_SAMO_Addr_Align()    => 6,
    E_SAMO_Access_Fault()  => 7,
    E_U_EnvCall()          => 8,
    E_S_EnvCall()          => 9,
    E_Reserved_10()        => 10,
    E_M_EnvCall()          => 11,
    E_Fetch_Page_Fault()   => 12,
    E_Load_Page_Fault()    => 13,
    E_Reserved_14()        => 14,
    E_SAMO_Page_Fault()    => 15,

    /* extensions */
    E_Extension(e)         => num_of_ext_exc_type(e)

  }

type exc_code = bits(8)

val ext_exc_type_to_bits : ext_exc_type -> exc_code
function ext_exc_type_to_bits(e) = 0x18

val exceptionType_to_bits : ExceptionType -> exc_code
function exceptionType_to_bits(e) =
  match (e) {
    E_Fetch_Addr_Align()   => 0x00,
    E_Fetch_Access_Fault() => 0x01,
    E_Illegal_Instr()      => 0x02,
    E_Breakpoint()         => 0x03,
    E_Load_Addr_Align()    => 0x04,
    E_Load_Access_Fault()  => 0x05,
    E_SAMO_Addr_Align()    => 0x06,
    E_SAMO_Access_Fault()  => 0x07,
    E_U_EnvCall()          => 0x08,
    E_S_EnvCall()          => 0x09,
    E_Reserved_10()        => 0x0a,
    E_M_EnvCall()          => 0x0b,
    E_Fetch_Page_Fault()   => 0x0c,
    E_Load_Page_Fault()    => 0x0d,
    E_Reserved_14()        => 0x0e,
    E_SAMO_Page_Fault()    => 0x0f,

    /* extensions */
    E_Extension(e)         => ext_exc_type_to_bits(e)
  }

val privLevel_to_bits : Privilege -> priv_level
function privLevel_to_bits (p) =
  match (p) {
    User       => 0b00,
    Supervisor => 0b01,
    Machine    => 0b11
  }

type tv_mode = bits(2)
enum TrapVectorMode = {TV_Direct, TV_Vector, TV_Reserved}

val trapVectorMode_of_bits : tv_mode -> TrapVectorMode
function trapVectorMode_of_bits (m) =
  match (m) {
    0b00 => TV_Direct,
    0b01 => TV_Vector,
    _    => TV_Reserved
  }

// extensions def
scattered enum extension
enum clause extension = Ext_I
enum clause extension = Ext_A
enum clause extension = Ext_M
enum clause extension = Ext_F
enum clause extension = Ext_D
enum clause extension = Ext_C
enum clause extension = Ext_B
enum clause extension = Ext_V
enum clause extension = Ext_S
enum clause extension = Ext_U
enum clause extension = Ext_Zicbom
enum clause extension = Ext_Zicboz
enum clause extension = Ext_Zicntr
enum clause extension = Ext_Zicond
enum clause extension = Ext_Zifencei
enum clause extension = Ext_Zihpm
enum clause extension = Ext_Zmmul
enum clause extension = Ext_Zaamo
enum clause extension = Ext_Zabha
enum clause extension = Ext_Zalrsc
enum clause extension = Ext_Zfa
enum clause extension = Ext_Zfh
enum clause extension = Ext_Zfhmin
enum clause extension = Ext_Zfinx
enum clause extension = Ext_Zdinx
enum clause extension = Ext_Zca
enum clause extension = Ext_Zcb
enum clause extension = Ext_Zcd
enum clause extension = Ext_Zcf
enum clause extension = Ext_Zba
enum clause extension = Ext_Zbb
enum clause extension = Ext_Zbc
enum clause extension = Ext_Zbkb
enum clause extension = Ext_Zbkc
enum clause extension = Ext_Zbkx
enum clause extension = Ext_Zbs
enum clause extension = Ext_Zknd
enum clause extension = Ext_Zkne
enum clause extension = Ext_Zknh
enum clause extension = Ext_Zkr
enum clause extension = Ext_Zksed
enum clause extension = Ext_Zksh
enum clause extension = Ext_Zhinx
enum clause extension = Ext_Sscofpmf
enum clause extension = Ext_Sstc
enum clause extension = Ext_Svinval
enum clause extension = Ext_Svnapot
enum clause extension = Ext_Svpbmt
enum clause extension = Ext_Smcntrpmf

val extensionEnabled : extension -> bool
scattered function extensionEnabled