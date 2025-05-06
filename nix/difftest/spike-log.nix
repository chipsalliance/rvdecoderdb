{
  stdenv,
  dtc,
  callPackage,
  rv32-stdenv,
}:

let
  spike = callPackage ./spike.nix { dtc = dtc; };
  riscv-tests = callPackage ./riscv-tests.nix { inherit rv32-stdenv; };
  spikeArgs = ''--isa=rv32gc --log-commits '';
  vm = "rv32ui-p-*";
in

stdenv.mkDerivation {
  name = "spike-log";
  src = null;

  inherit spike riscv-tests;

  buildInputs = [
    spike
    riscv-tests
    dtc
  ];

  unpackPhase = '':'';

  buildPhase = ''
    mkdir -p $TMPDIR/logs
    for test in ${riscv-tests}/${rv32-stdenv.targetPlatform.config}/share/riscv-tests/isa/${vm}; do
      if [[ ! $test =~ \.dump$ ]]; then
        echo "Running test: $test"
        ${spike}/bin/spike ${spikeArgs} $test > $TMPDIR/logs/$(basename $test).log || true
      fi
    done
  '';

  installPhase = ''
    mkdir -p $out/tests/ $out/logs/
    cp ${spike}/bin/spike $out/
    cp ${riscv-tests}/${rv32-stdenv.targetPlatform.config}/share/riscv-tests/isa/* $out/tests/
    cp $TMPDIR/logs/* $out/logs/
  '';
}
