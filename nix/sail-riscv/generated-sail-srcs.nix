{
  lib,
  runCommand,
  sailcodegen,
  riscv-opcodes-src,
}:

let
  sail-impl =
    with lib.fileset;
    toSource {
      fileset = unions [
        ../../sail-impl/csr
        ../../sail-impl/inst
        ../../sail-impl/rvcore
        ../../sail-impl/sail-impl-meta.json
        ../../sail-impl/sail_impl.h
        ../../sail-impl/makefile
      ];
      root = ../../sail-impl;
    };
in
runCommand "generate-sail-srcs" { nativeBuildInputs = [ sailcodegen ]; } ''
  mkdir -p "$out" build
  sailcodegen \
    --riscv-opcodes-path ${riscv-opcodes-src} \
    --sail-impl-dir ${sail-impl} \
    --output-dir build

  cp -rv build/* "$out"/
  cp -rv ${sail-impl}/* "$out"/
''
