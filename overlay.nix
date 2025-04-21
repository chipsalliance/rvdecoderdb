final: prev: {
  mill =
    let
      jre = final.jdk21;
    in
    (prev.mill.override { inherit jre; }).overrideAttrs rec {
      version = "0.12.8-1-46e216";
      src = final.fetchurl {
        url = "https://repo1.maven.org/maven2/com/lihaoyi/mill-dist/${version}/mill-dist-${version}-assembly.jar";
        hash = "sha256-XNtl9NBQPlkYu/odrR/Z7hk3F01B6Rk4+r/8tMWzMm8=";
      };
      # Re-export JRE to share Java toolchain usage
      passthru = { inherit jre; };
    };

  espresso = final.callPackage ./nix/espresso.nix { };

  rvdecoderdb-jvm = final.callPackage ./nix/rvdecoderdb-jvm.nix { };

  riscv-opcodes-src = final.fetchFromGitHub {
    owner = "riscv";
    repo = "riscv-opcodes";
    rev = "8899b32f218c85bf2559fa95f226bc2533316802";
    fetchSubmodules = false;
    sha256 = "sha256-7CV/T8gnE7+ZPfYbn38Zx8fYUosTc8bt93wk5nmxu2c=";
  };

  sail-riscv = final.callPackage ./nix/sail-riscv/all-pkgs.nix { };
}
