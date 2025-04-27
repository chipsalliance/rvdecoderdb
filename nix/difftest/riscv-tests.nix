{ rv32-stdenv, fetchFromGitHub }:

rv32-stdenv.mkDerivation {
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
    "--prefix=${placeholder "out"}/${rv32-stdenv.targetPlatform.config}"
  ];
  buildPhase = "make RISCV_PREFIX=${rv32-stdenv.targetPlatform.config}-";
}
