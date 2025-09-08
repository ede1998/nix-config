{
  inputs,
  outputs,
  lib,
  ...
}:
{
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    outputs.homeModules.initial-files
    outputs.homeModules.initial-config
    outputs.homeModules.thunderbird

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default
    inputs.plasma-manager.homeModules.plasma-manager
    inputs.nextcloud-tag-sync.homeModules.nextcloud-tag-sync

    # You can also split up your configuration and import pieces of it here:
    ./auto-pull.nix
    ./firefox.nix
    ./gaming.nix
    ./gnucash
    ./home.nix
    ./koi.nix
    ./nextcloud.nix
    ./openscad.nix
    ./pkgs.nix
    ./plasma.nix
    ./terminal
    ./thunderbird
    ./vorta
    ./vscode
  ];

  programs.plasma = {
    powerdevil.AC = {
      autoSuspend.action = "nothing";
      turnOffDisplay = {
        idleTimeout = 900;
      };
    };
    kscreenlocker.timeout = 120;
    configFile = {
      # Digital clock
      # TODO also automatically configure those calendars
      # at the moment, I added these manually via
      # nix run nixpkgs#kdePackages.akonadiconsole
      # and add davgroupware resource
      plasmashellrc.PIMEventsPlugin.calendars = lib.strings.concatStringsSep "," [
        "15"
        "16"
        "17"
        "18"
      ];
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
