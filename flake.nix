{
  description = "rvdecoderdb";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Don't follow mill-ivy-fetcher to this flake, it needs a pinned nixpkgs.
    mill-ivy-fetcher.url = "github:Avimitin/mill-ivy-fetcher";
  };

  outputs =
    {
      self,
      nixpkgs,
      mill-ivy-fetcher,
      flake-parts,
      treefmt-nix,
      ...
    }@inputs:
    let
      overlay = import ./overlay.nix;
    in
    flake-parts.lib.mkFlake { inherit inputs; } (_: {
      systems = builtins.filter (
        system: builtins.hasAttr system nixpkgs.legacyPackages
      ) nixpkgs.lib.platforms.all;

      flake = {
        overlays.default = overlay;
      };

      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem =
        { system, ... }:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              overlay
              mill-ivy-fetcher.overlays.default
            ];
          };
        in
        {
          _module.args.pkgs = pkgs;

          legacyPackages = pkgs;

          devShells = {
            default = pkgs.mkShell {
              buildInputs = [
                pkgs.mill
                pkgs.espresso
              ];
            };

            sailEnv = pkgs.mkShell {
              packages = with pkgs; [
                ccls
                metals
                sail-riscv.sail
              ];

              inputsFrom = with pkgs.sail-riscv; [
                sailcodegen
              ];
            };
          };

          treefmt = {
            projectRootFile = "flake.nix";
            settings.on-unmatched = "debug";
            programs = {
              nixfmt.enable = true;
              scalafmt.enable = true;
              rustfmt.enable = true;
            };
            settings.formatter = {
              nixfmt.excludes = [ "*/generated.nix" ];
              scalafmt.includes = [
                "*.sc"
                "*.mill"
              ];
            };
          };
        };
    });
}
