{ stdenv
, ocamlPackages
, fetchFromGitHub
, lib
, fetchMillDeps
, mill
, z3
, gmp
, zlib
, rustPlatform
, pkgs
, tree
}:

let
  # Rust部分构建
  rustDeps = rustPlatform.buildRustPackage rec {
    pname = "sail-rust";
    version = "0.1.0";
    
    src = ../sailcodegen/jvm/src/sail/rust;
    
    cargoLock = {
      lockFile = src + /Cargo.lock;
      outputHashes = {};
    };

    buildType = "release";
  };

  sailCodeGenSrc = with lib.fileset; toSource {
    fileset = unions [
      ../build.mill
      ../common.mill
      ../sailcodegen
      ../rvdecoderdb
    ];
    root = ../.;
  };
  sailCodeGenDeps = fetchMillDeps {
    name = "sailCodeGen";
    src = sailCodeGenSrc;
    millDepsHash = "sha256-j6ixFkxLsm8ihDLFkkJDePVuS2yVFmX3B1gOUVguCHQ=";
  };
  rvdecoderdbDeps = fetchMillDeps {
    name = "rvdecoderdb";
    src = sailCodeGenSrc;
    millDepsHash = "sha256-j6ixFkxLsm8ihDLFkkJDePVuS2yVFmX3B1gOUVguCHQ=";
  };
in

let
  ocamlPackages' = ocamlPackages.overrideScope (finalScope: prevScope: {
    sail = prevScope.sail.overrideAttrs rec {
      version = "0.18";
      src = fetchFromGitHub {
        owner = "rems-project";
        repo = "sail";
        rev = version;
        hash = "sha256-QvVK7KeAvJ/RfJXXYo6xEGEk5iOmVsZbvzW28MHRFic=";
      };

      buildInputs = [ finalScope.menhirLib ];
    };
  });
  riscv-opcodes = {
    src = fetchFromGitHub {
      owner = "riscv";
      repo = "riscv-opcodes";
      rev = "8899b32f218c85bf2559fa95f226bc2533316802";
      fetchSubmodules = false;
      sha256 = "sha256-7CV/T8gnE7+ZPfYbn38Zx8fYUosTc8bt93wk5nmxu2c=";
    };
  };
in


stdenv.mkDerivation {
  name = "sailcodegen";
  src = sailCodeGenSrc;
  inherit rustDeps;

  nativeBuildInputs = with ocamlPackages'; [
    ocamlbuild
    findlib
    ocaml
    z3
    sail
    mill
    rvdecoderdbDeps.setupHook
    gmp
    zlib
  ];

  buildInputs = with riscv-opcodes; [
    sailCodeGenDeps.setupHook
    ocamlPackages'.sail
    rustDeps
  ];

  buildPhase = ''
    runHook preBuild
    cp -r ${riscv-opcodes.src} sailcodegen/jvm/riscv-opcodes
    export SAIL_FLAGS="--require-version 0.18 --strict-var -dno_cast"
    mill -i 'sailcodegen.jvm.runMain' sailCodeGen rv64i

    sail $SAIL_FLAGS -O -Oconstant_fold -memo_z3 -c --c-include ../c/lib.h \
      -c_no_main \
      ./sailcodegen/jvm/src/sail/rvcore/lib/prelude.sail \
      ./sailcodegen/jvm/src/sail/rvcore/rv_xlen.sail \
      ./sailcodegen/jvm/src/sail/rvcore/capi.sail \
      ./sailcodegen/jvm/src/sail/rvcore/lib/scattered.sail \
      ./sailcodegen/jvm/src/sail/rvcore/arch/ArchPrelude.sail \
      ./sailcodegen/jvm/src/sail/rvcore/arch/ArchStatesPrivEnable.sail \
      ./sailcodegen/jvm/src/sail/rvcore/arch/ArchStateCsrBF.sail \
      ./sailcodegen/jvm/src/sail/rvcore/arch/ArchStates.sail \
      ./sailcodegen/jvm/src/sail/rvcore/arch/ArchStatesRW.sail \
      ./sailcodegen/jvm/src/sail/rvcore/arch/ArchStatesReset.sail \
      ./sailcodegen/jvm/src/sail/rvcore/rv_core.sail \
      ./sailcodegen/jvm/src/sail/rvcore/sailexpose.sail \
      -o ./sailcodegen/jvm/src/sail/rvcore/rv_model

    cc -c -I ${ocamlPackages'.sail.src}/lib \
      -I sail/c \
      ${ocamlPackages'.sail.src}/lib/*.c \
      ./sailcodegen/jvm/src/sail/rvcore/rv_model.c \
      -lgmp -lz

    

    cc -g \
      -I ${ocamlPackages'.sail.src}/lib \
      ./rv_model.o \
      ${ocamlPackages'.sail.src}/lib/*.c \
      ${rustDeps}/lib/libsail_rust_ffi.a \
      -lgmp -lz -lpthread -ldl \
      -o ./sailcodegen/jvm/src/rv

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp ./sailcodegen/jvm/src/rv $out/bin/
    runHook postInstall
  '';
}
