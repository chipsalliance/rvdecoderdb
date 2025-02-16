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
