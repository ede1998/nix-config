# This file defines overlays
{ inputs }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications =
    final: prev:
    let
      addPatches =
        pkg: patches:
        pkg.overrideAttrs (oldAttrs: {
          patches = (oldAttrs.patches or [ ]) ++ patches;
        });
      # Rust packages need special handling: https://nixos.wiki/wiki/Overlays
      addRustPatches =
        pkg: patches: cargoHash:
        pkg.overrideAttrs (oldAttrs: rec {
          pname = oldAttrs.pname;
          version = oldAttrs.version;

          # take the original source and apply all patches before making it the new source
          # we cannot use patches or patchPhase because all dependencies are vendored into
          # a separate derivation before the patch phase resulting in mismatching Cargo.lock
          # checksums
          src = prev.runCommand "patched-source" { } ''
            cp --no-preserve=mode -r ${oldAttrs.src} $out
            cd $out
            ${prev.lib.concatMapStringsSep "\n" (patch: ''patch -p1 < "${patch}"'') patches}
          '';
          cargoDeps = oldAttrs.cargoDeps.overrideAttrs (
            prev.lib.const {
              name = "${pname}-vendor.tar.gz";
              inherit src;
              outputHash = cargoHash;
            }
          );
        });
    in
    {
      vorta = addPatches prev.vorta [
        (builtins.fetchurl {
          url = "https://patch-diff.githubusercontent.com/raw/borgbase/vorta/pull/2068.patch";
          sha256 = "sha256:1das1vk1g0j5mfb7diaf3gs8vkdvqkssj8j6y50kfh38n600fcsf";
        })
      ];
      fclones = addRustPatches prev.fclones [
        (builtins.fetchurl {
          url = "https://patch-diff.githubusercontent.com/raw/pkolaczk/fclones/pull/280.patch";
          sha256 = "sha256:0inir6g158hfc4a1s2hwsbr887szb6mzpm961xjpisy1vgbjg9hy";
        })
      ] "sha256-vHr1sVGrtJyZp+y1ukwDgkPaGfyYHxHUrlAqjnKfTEo=";
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
