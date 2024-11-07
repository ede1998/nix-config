# This file defines overlays
{ inputs }:
let
  addPatches =
    pkg: patches:
    pkg.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ patches;
    });
  # Rust packages need special handling: https://nixos.wiki/wiki/Overlays
  addRustPatches' =
    prev: pkg: patches: cargoHash:
    pkg.overrideAttrs (oldAttrs: rec {
      # take the original source and apply all patches before making it the new source
      # we cannot simply override patches or patchPhase because all dependencies are vendored into
      # a separate derivation before the patch phase resulting in mismatching Cargo.lock
      # checksums
      # applyPatches from trivialBuilders:
      # https://github.com/NixOS/nixpkgs/blob/24.05/pkgs/build-support/trivial-builders/default.nix#L852
      src = prev.applyPatches {
        inherit (oldAttrs) src;
        inherit patches;
      };
      cargoDeps = oldAttrs.cargoDeps.overrideAttrs (
        prev.lib.const {
          inherit src;
          outputHash = cargoHash;
        }
      );
    });
in
{
  # This one brings our custom packages from the 'pkgs' directory
  additions =
    final: prev:
    import ../pkgs final.pkgs
    // {
      external-flake.rip2 = inputs.rip2.packages.${prev.pkgs.system}.default;
    };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications =
    final: prev:
    let
      addRustPatches = addRustPatches' prev;
      fclones-with-completions = addRustPatches prev.fclones [
        (builtins.fetchurl {
          url = "https://patch-diff.githubusercontent.com/raw/pkolaczk/fclones/pull/280.patch";
          sha256 = "sha256:0inir6g158hfc4a1s2hwsbr887szb6mzpm961xjpisy1vgbjg9hy";
        })
      ] "sha256-o+jsVnw9FvaKagiEVGwc+l0hE25X+KYY36hFhJwlcj0=";
    in
    {
      vorta = addPatches prev.vorta [
        (builtins.fetchurl {
          url = "https://patch-diff.githubusercontent.com/raw/borgbase/vorta/pull/2068.patch";
          sha256 = "sha256:1das1vk1g0j5mfb7diaf3gs8vkdvqkssj8j6y50kfh38n600fcsf";
        })
      ];

      fclones = fclones-with-completions.overrideAttrs (oldAttrs: {
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ prev.installShellFiles ];
        postInstall =
          (oldAttrs.postInstall or "")
          + ''
            # setting PATH required so completion script doesn't use full path
            export PATH="$PATH:$out/bin"
            installShellCompletion --cmd $pname \
              --bash <(fclones complete bash) \
              --fish <(fclones complete fish) \
              --zsh <(fclones complete zsh)
          '';
      });

      kdePackages = prev.kdePackages.overrideScope (
        final: prev: {
          konsole = addPatches prev.konsole [
            # Backport of https://invent.kde.org/utilities/konsole/-/merge_requests/767"
            ./konsole-osc52-support.patch
          ];
        }
      );
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
