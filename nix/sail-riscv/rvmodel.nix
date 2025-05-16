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

  src = ../../sail-impl/model;

  makeFlags = [
    "SAIL_SRC_DIR=${sail}/share/sail/lib"
    "GENERATED_SAIL_SRC_DIR=${generated-sail-srcs}"
    "prefix=${placeholder "out"}"
  ];
}
