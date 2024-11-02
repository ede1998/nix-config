# This file defines overlays
{ inputs }:
let
  lib = inputs.nixpkgs.lib;
  addPatches =
    pkg: patches:
    pkg.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ patches;
    });
  # Rust packages need special handling: https://nixos.wiki/wiki/Overlays
  addRustPatchedSrc =
    pkg: src: cargoHash:
    pkg.overrideAttrs (oldAttrs: rec {
      pname = oldAttrs.pname;
      version = oldAttrs.version;

      inherit src;
      cargoDeps = oldAttrs.cargoDeps.overrideAttrs (
        lib.const {
          name = "${pname}-vendor.tar.gz";
          inherit src;
          outputHash = cargoHash;
        }
      );
    });
in
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    vorta = addPatches prev.vorta [
      (builtins.fetchurl {
        url = "https://patch-diff.githubusercontent.com/raw/borgbase/vorta/pull/2068.patch";
        sha256 = "sha256:1das1vk1g0j5mfb7diaf3gs8vkdvqkssj8j6y50kfh38n600fcsf";
      })
    ];
    fclones = addRustPatchedSrc prev.fclones (prev.fetchFromGitHub {
      owner = "ede1998";
      repo = "fclones";
      rev = "e45aa68d07cf5294f76fb528649c6926613d5750";
      sha256 = "sha256-EBkm2BmkNXXXtXapF54zLa9aeclMLPneL9iAgxFHGFo=";
    }) "sha256-vHr1sVGrtJyZp+y1ukwDgkPaGfyYHxHUrlAqjnKfTEo=";
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
