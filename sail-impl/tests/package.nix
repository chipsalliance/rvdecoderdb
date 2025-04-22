{ rv64-stdenv }:
rv64-stdenv.mkDerivation {
  name = "rv64i-add.elf";

  src = ./.;

  makeFlags = [
    "RISCV_PREFIX=${rv64-stdenv.targetPlatform.config}"
    "PREFIX=${placeholder "out"}"
  ];

  dontFixup = true;
}
