{ pkgsCross, fetchFromGitHub }:

pkgsCross.riscv32-embedded.stdenv.mkDerivation {
  name = "riscv-tests";
  src = fetchFromGitHub {
    owner = "riscv-software-src";
    repo = "riscv-tests";
    rev = "b6941920e88c5c751b03f9a3b88c01f7309a35af";
    hash = "sha256-MChjeJcmPeQeDr52rT0aUIdYa821SKIWHpcCLN4GHsg=";
    fetchSubmodules = true;
  };

  enableParallelBuilding = true;

  configureFlags = [
    # to match rocket-tools path
    "--prefix=${placeholder "out"}/riscv32-unknown-elf"
  ];
  buildPhase = "make RISCV_PREFIX=riscv32-none-elf-";
}
