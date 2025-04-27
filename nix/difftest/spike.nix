{
  stdenv,
  dtc,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  version = "unstable-2024-07-03";
  pname = "spike";

  nativeBuildInputs = [ dtc ];
  enableParallelBuilding = true;
  separateDebugInfo = true;
  src = fetchFromGitHub {
    owner = "riscv";
    repo = "riscv-isa-sim";
    rev = "488e07d75df85d4bb363076dbb40b45288a2fad0";
    hash = "sha256-aNYSlbl2p9VXPw0liDDRNgpHaZ24r59Qu+HG2zfETro=";
  };
  configureFlags = [
    "--enable-commitlog"
  ];
}
