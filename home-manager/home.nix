{
  inputs,
  outputs,
  pkgs,
  hostName,
  ...
}:
{
  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default
      inputs.nix-vscode-extensions.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };
  xdg.configFile."nixpkgs/config.nix".text = "{ allowUnfree = true; }";

  programs.home-manager.enable = true;
  services.home-manager.autoExpire = {
    enable = true;
    frequency = "weekly";
    timestamp = "-90 days";
  };
  nix = {
    package = pkgs.nix;
    # Not sure if substituters is required again here if it is already part of the NixOS configuration.
    settings.substituters = [
      "https://cache.nixos.org"
      "https://cache.garnix.io"
    ];
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  initial-config.bitwarden-desktop = {
    enable = true;
    email = "bitwarden@erik-hennig.me";
  };

  home = rec {
    username = "erik";
    homeDirectory = "/home/erik";
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      NIXPKGS_ALLOW_UNFREE = "1";
    };
    shellAliases = with pkgs; {
      # for simple aliases that are cross-shell compatible
      code = "codium";
      home-manager = "home-manager --flake ${homeDirectory}/nix-config#${username}@${hostName}";
      nixos-rebuild = "sudo nixos-rebuild --flake ${homeDirectory}/nix-config#${hostName}";
      open = "xdg-open";
      datetime8601 = ''date -u +"%Y-%m-%dT%H-%M-%S"'';
      ll = "ls -lsah --color=auto";
      # execute command once for each line in stdin (as opposed to once with all lines as argument for normal xargs)
      trxargs = "tr '\n' '\0' | xargs -0 -n1";
      ".." = "z ..";
      "..." = "z ../..";
      "...." = "z ../../..";
      mv = "mv -i";
      cp = "cp -i";
      ln = "ln -i";
      rm = "rm -I";
      gis = "${git}/bin/git status";
      gip = "${git}/bin/git push";
      gic = "${git}/bin/git commit";
      gia = "${git}/bin/git add";
      gid = "${git}/bin/git diff";
      gids = "${git}/bin/git diff --staged";
      giu = "${git}/bin/git pull";
      gil = "${git}/bin/git log";
      gila = "${git}/bin/git log --oneline --decorate --all --graph";
      cdh = "cd `${git}/bin/git rev-parse --show-toplevel`";
    };
  };
}
