{ lib
, publishMillJar
, writeShellApplication
, mill
, mill-ivy-fetcher
}:
publishMillJar rec {
  name = "rvdecoderdb";

  src = with lib.fileset; toSource {
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
      sourceDir=$(mktemp -d -t 'rvdecoderdb_src_XXX')
      cp -rT ${src} "$sourceDir"/rvdecoderdb
      chmod -R u+w "$sourceDir"

      mif run \
        --targets rvdecoderdb.jvm \
        -p "$sourceDir"/rvdecoderdb \
        -o ./nix/rvdecoderdb-jvm-mill-lock.nix
    '';
  };
}
