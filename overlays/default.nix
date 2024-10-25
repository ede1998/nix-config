# This file defines overlays
{ inputs }:
let
  addPatches =
    pkg: patches:
    pkg.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ patches;
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
