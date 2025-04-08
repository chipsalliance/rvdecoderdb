{
  description = "rvdecoderdb";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    mill-ivy-fetcher = {
      url = "github:Avimitin/mill-ivy-fetcher";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };
  outputs = { self, nixpkgs, mill-ivy-fetcher, flake-utils }@inputs:
    let
      overlay = import ./overlay.nix;
    in
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; overlays = [ mill-ivy-fetcher.overlays.default overlay ]; };
          commonDeps = with pkgs; [
            mill
            espresso
            pkgs.mill-ivy-fetcher
          ];

        in
        {
          legacyPackages = pkgs;
          devShells = {
            default = pkgs.mkShell {
              buildInputs = commonDeps;
            };
          };
        }
      )
    // { inherit inputs; overlays.default = overlay; };
}
