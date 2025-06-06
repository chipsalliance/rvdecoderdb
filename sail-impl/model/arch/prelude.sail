scattered union ast

val execute : ast -> unit
scattered function execute

val encdec : ast <-> bits(32)
scattered mapping encdec

val encdec_compressed : ast <-> bits(16)
scattered mapping encdec_compressed

val ext_decode_compressed : bits(16) -> ast
function ext_decode_compressed(bv) = encdec_compressed(bv)

val ext_decode : bits(32) -> ast
function ext_decode(bv) = encdec(bv)

union clause ast = ILLEGAL : bits(32)
union clause ast = C_ILLEGAL : bits(16)

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

register PC : bits(64)

// GPR
type regidx  = bits(5)

val read_GPR : regidx -> bits(64)
scattered function read_GPR

val write_GPR : (regidx, bits(64)) -> unit
scattered function write_GPR

type cregidx = bits(3)

val creg2reg_idx : cregidx -> regidx
function creg2reg_idx(creg) = 0b01 @ creg

// CSR
type csreg   = bits(12)

val is_CSR_defined : (csreg) -> bool
scattered function is_CSR_defined

val read_CSR : csreg -> bits(64)
scattered function read_CSR

val write_CSR : (csreg, bits(64)) -> bool
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

val num_of_ext_exc_type : ext_exc_type -> {'n, (0 <= 'n < 64). int('n)}
function num_of_ext_exc_type(e) = 24

val num_of_ExceptionType : ExceptionType -> {'n, (0 <= 'n < 64). int('n)}
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

function trap_vector_mode_of_bits (m) : tv_mode -> TrapVectorMode =
  match (m) {
    0b00 => TV_Direct,
    0b01 => TV_Vector,
    _    => TV_Reserved
  }
function trap_vector_mode_to_bits (m) : TrapVectorMode -> tv_mode =
  match (m) {
    TV_Direct => 0b00,
    TV_Vector => 0b01,
    TV_Reserved => 0b00,
  }

// an external hook that get applied *before* register get written.
val write_GPR_hook = pure "write_GPR_hook" : (regidx, bits(64)) -> unit

val inst_fetch = pure "inst_fetch" : bits(64) -> bits(32)
val fence_i = pure "fence_i" : (bits(4), bits(4)) -> unit
val is_reset = pure "is_reset" : unit -> bool

// phy_read* API all have one argument `address` with `bits(64)` width, return
// specific length value from that given address.
val phy_read_byte = pure "phy_read_byte" : bits(64) -> bits(8)
val phy_read_half_word = pure "phy_read_half_word" : bits(64) -> bits(16)
val phy_read_word = pure "phy_read_word" : bits(64) -> bits(32)
val phy_read_double_word = pure "phy_read_double_word" : bits(64) -> bits(64)

// phy_write* API accept two arguments, write specific length data from the
// second argument `value` to the first argument `address`.
val phy_write_byte = pure "phy_write_byte" : (bits(64), bits(8)) -> unit
val phy_write_half_word = pure "phy_write_half_word" : (bits(64), bits(16)) -> unit
val phy_write_word = pure "phy_write_word" : (bits(64), bits(32)) -> unit
val phy_write_double_word = pure "phy_write_double_word" : (bits(64), bits(64)) -> unit

val exception_raised = pure "exception_raised" : unit -> bool
