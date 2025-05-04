{
  inputs,
  outputs,
  ...
}:
{
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    outputs.homeManagerModules.initial-files
    outputs.homeManagerModules.initial-config

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default
    inputs.plasma-manager.homeManagerModules.plasma-manager

    # You can also split up your configuration and import pieces of it here:
    ./auto-pull.nix
    ./firefox.nix
    ./home.nix
    ./koi.nix
    ./openscad.nix
    ./pkgs.nix
    ./plasma.nix
    ./terminal
    ./vscode
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
