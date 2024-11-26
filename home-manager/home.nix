# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  config,
  pkgs,
  hostName,
  ...
}:
{
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    outputs.homeManagerModules.initial-files
    outputs.homeManagerModules.initial-config
    outputs.homeManagerModules.thunderbird

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default
    inputs.plasma-manager.homeManagerModules.plasma-manager

    # You can also split up your configuration and import pieces of it here:
    ./auto-pull.nix
    ./firefox.nix
    ./gnucash
    ./pkgs.nix
    ./plasma.nix
    ./terminal
    ./thunderbird
    ./vscode
  ];

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

  services.gpg-agent = {
    enable = true;
    enableBashIntegration = true;
    defaultCacheTtl = 3600;
    maxCacheTtl = 999999;
    pinentryPackage = pkgs.pinentry;
  };

  #xdg = {
  #  enable = true;
  #
  # Cura config does not work well, program seems to ignore it when it's write-only
  #  dataFile."cura" = {
  #    source = ./cura/.local/share;
  #    recursive = true;
  #  };
  #  configFile."cura".source = ./cura/.config;
  #};

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  initial-config = {
    bitwarden-desktop = {
      enable = true;
      email = "bitwarden@erik-hennig.me";
    };
    discord = {
      enable = true;
      auto_start = true;
    };
    nextcloud-client = {
      enable = hostName == "babbage";
      start-in-background = true;
      user = "erik";
      instance-url = "https://cloud.erik-hennig.me";
      folder-sync = {
        "/Documents" = {
          localPath = "${config.home.homeDirectory}/Documents";
          ignoreHiddenFiles = false;
        };
        "/Pictures" = {
          localPath = "${config.home.homeDirectory}/Pictures";
          ignoreHiddenFiles = false;
        };
        "/shared" = {
          localPath = "${config.home.homeDirectory}/nextcloud-shared";
          ignoreHiddenFiles = false;
        };
      };
    };
    vorta = {
      enable = true;
      profiles = [
        ./vorta-profiles/HDD.json
        ./vorta-profiles/NAS.json
      ];
    };
    koi = {
      enable = true;
      auto-start = true;
      force = true;
      General.notify-on-swap = false;
      ColorScheme = {
        enable = true;
        dark = "${pkgs.kdePackages.breeze}/share/color-schemes/BreezeDark.colors";
        light = "${pkgs.kdePackages.breeze}/share/color-schemes/BreezeLight.colors";
      };
      GTKTheme = {
        enable = true;
        dark = "Breeze-Dark";
        light = "Breeze";
      };
      IconTheme = {
        enable = true;
        dark = "breeze-dark";
        light = "Breeze_Light";
      };
      PlasmaStyle = {
        enable = true;
        dark = "breeze-dark";
        light = "breeze-light";
      };
    };
  };

  home = rec {
    username = "erik";
    homeDirectory = "/home/erik";
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

    file."${config.xdg.configHome}/autostart/steam.desktop".source = "${pkgs.steam}/share/applications/steam.desktop";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.05";
  };
}
