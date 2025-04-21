{
  stdenv,
  sail,
  z3,
  gmp,
  zlib,
  generated-sail-srcs,
}:

stdenv.mkDerivation {
  name = "sail-rv-model";

  nativeBuildInputs = [
    sail
    z3
  ];

  buildInputs = [
    gmp
    zlib
  ];

  src = generated-sail-srcs;

  makeFlags = [
    "SAIL_SRC_DIR=${sail}/share/sail/lib"
    "prefix=${placeholder "out"}"
  ];
}
