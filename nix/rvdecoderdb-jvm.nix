{
  lib,
  publishMillJar,
  writeShellApplication,
  mill,
  mill-ivy-fetcher,
}:
publishMillJar rec {
  name = "rvdecoderdb";

  src =
    with lib.fileset;
    toSource {
      fileset = unions [
        ../build.mill
        ../common.mill
        ../rvdecoderdb
      ];
      root = ../.;
    };

  publishTargets = [
    "rvdecoderdb.jvm"
  ];

  lockFile = ./rvdecoderdb-jvm-mill-lock.nix;

  passthru.bump = writeShellApplication {
    name = "bump-rvdecoderdb";
    runtimeInputs = [
      mill
      mill-ivy-fetcher
    ];
    text = ''
      mif run \
        --targets rvdecoderdb.jvm \
        -p ${src} \
        -o ./nix/rvdecoderdb-jvm-mill-lock.nix \
        "$@"
    '';
  };
}
