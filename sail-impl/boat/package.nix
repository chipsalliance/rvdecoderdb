{
  lib,
  rustPlatform,
  sail,
  rvmodel,
  gmp,
  rust-analyzer,
}:
let
  builder =
    name:
    let
      self = rustPlatform.buildRustPackage {
        inherit name;

        src = lib.cleanSource ./.;

        buildAndTestSubdir = "./${name}";

        buildInputs = [
          rustPlatform.bindgenHook
          sail.dev
          gmp
        ];

        env = {
          RVMODEL_LIB_DIR = "${rvmodel}/lib";
          GMP_LIB_DIR = "${gmp}/lib";
        };

        passthru.dev = self.overrideAttrs (old: {
          nativeBuildInputs = old.nativeBuildInputs ++ [
            rust-analyzer
          ];
        });

        cargoLock = {
          lockFile = ./Cargo.lock;
        };
      };
    in
    self;
in
{
  emulator = builder "emulator";
  sail_ffi = builder "sail_ffi";
}
