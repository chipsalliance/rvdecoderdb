{
  lib,
  stdenv,
  makeWrapper,
  writeShellApplication,

  mill,
  mill-ivy-fetcher,
  riscv-opcodes-src,
  ivy-gather,
  add-determinism-hook,
}:
let
  ivyCache = ivy-gather ./sailcodegen-mill-lock.nix;
in
stdenv.mkDerivation rec {
  name = "sailcodegen-jar";

  src =
    with lib.fileset;
    toSource {
      root = ./../../..;
      fileset = unions [
        ../../../build.mill
        ../../../common.mill
        ../../../sailcodegen
        ../../../rvdecoderdb
      ];
    };

  nativeBuildInputs = [
    makeWrapper
    add-determinism-hook
  ];

  propagatedBuildInputs = [
    mill
  ];

  buildInputs = [ ivyCache ];

  passthru = {
    inherit ivyCache;
    bump = writeShellApplication {
      name = "bump-sailcodegen-jar-lock";
      runtimeInputs = [
        mill
        mill-ivy-fetcher
      ];
      text = ''
        mif run --project-dir ${src} \
          --targets 'sailcodegen' \
          -o ./nix/sail-riscv/sailcodegen-jar/sailcodegen-mill-lock.nix "$@"
      '';
    };
  };

  buildPhase = ''
    runHook preBuild

    cp -rT ${riscv-opcodes-src} sailcodegen/riscv-opcodes
    mill -i 'sailcodegen.assembly'

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/java

    mv out/sailcodegen/assembly.dest/out.jar $out/share/java/sailcodegen.jar

    mkdir -p $out/bin
    makeWrapper ${mill.jre}/bin/java $out/bin/sailcodegen \
      --add-flags "-jar $out/share/java/sailcodegen.jar"

    runHook postInstall
  '';

  meta.mainProgram = "mif";
}
