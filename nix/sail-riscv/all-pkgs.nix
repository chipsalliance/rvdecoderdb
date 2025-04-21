{
  lib,
  newScope,
  fetchFromGitHub,
  ocamlPackages,
}:
lib.makeScope newScope (sailRiscvPkgs: {
  ocamlPackages = ocamlPackages.overrideScope (
    finalScope: prevScope: {
      sail = prevScope.sail.overrideAttrs (oldAttr: rec {
        # Override from 0.16 -> 0.19
        version = "0.19";
        src = fetchFromGitHub {
          owner = "rems-project";
          repo = "sail";
          rev = version;
          hash = "sha256-PhMypsXJs3S/4gWPX/NmPZg2gpwsE56waIcrQub44n0=";
        };

        outputs = [
          "out"
          "dev"
        ];

        postInstall = ''
          mkdir -p "$dev/include"
          cp "$out/share/sail/lib/sail.h" "$dev/include"
        '';
      });
    }
  );

  # alias
  sail = sailRiscvPkgs.ocamlPackages.sail;

  sailcodegen = sailRiscvPkgs.callPackage ./sailcodegen-jar/package.nix { };

  generated-sail-srcs = sailRiscvPkgs.callPackage ./generated-sail-srcs.nix { };

  rvmodel = sailRiscvPkgs.callPackage ./make-sail-rvmodel.nix { };

  boat = sailRiscvPkgs.callPackage ../../sail-impl/boat/package.nix { };
})
