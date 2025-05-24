# This file defines overlays
{ inputs }:
let
  addPatches =
    pkg: patches:
    pkg.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ patches;
    });
  # Rust packages need special handling: https://nixos.wiki/wiki/Overlays
  _addRustPatches' =
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
  additions = final: prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications =
    final: prev:
    let
      _addRustPatches = _addRustPatches' prev;
    in
    {
      xan = prev.xan.overrideAttrs (oldAttrs: {
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ prev.installShellFiles ];
        postInstall =
          (oldAttrs.postInstall or "")
          + (prev.lib.optionalString (prev.stdenv.buildPlatform.canExecute prev.stdenv.hostPlatform) ''
            installShellCompletion --cmd $pname \
              --bash <($out/bin/xan completions bash) \
              --zsh <($out/bin/xan completions zsh)
          '');
      });

      nix-update = addPatches prev.nix-update [
        (builtins.fetchurl {
          # Make --override-filename work for flakes and prevent error in git diff
          url = "https://patch-diff.githubusercontent.com/raw/Mic92/nix-update/pull/301.patch";
          sha256 = "sha256:10lc6ag5x3wwzab765r1x2fxwd1syl4zj8p3dq1dcn650spk7yx0";
        })
      ];
    };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages =
    final: prev:
    let
      pkgs = import inputs.nixpkgs-unstable {
        system = final.system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            # Fluffychat uses olm which is deprecated. Issue: https://github.com/krille-chan/fluffychat/issues/1258
            "fluffychat-linux-1.26.1"
            "fluffychat-linux-1.26.0" # TODO remove later
            "olm-3.2.16"
          ];
        };
      };
    in
    {
      unstable = pkgs // {
        fclones = pkgs.fclones.overrideAttrs (oldAttrs: {
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

      };
    };
}
