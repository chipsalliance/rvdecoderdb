{
  runCommand,
  sailcodegen,
  riscv-opcodes-src,
}:

runCommand "generate-sail-srcs" { nativeBuildInputs = [ sailcodegen ]; } ''
  mkdir -p build
  sailcodegen \
    --riscv-opcodes-path ${riscv-opcodes-src} \
    --model-dir "${../../sail-impl/model}" \
    --output-dir "build"

  cp -rvT build "$out"
''
