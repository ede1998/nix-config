{ config, ... }:
{
  programs.navi = {
    enable = true;
    settings = {
      cheats.paths = [ "${config.home.homeDirectory}/nix-config/home-manager/terminal/navi" ];
    };
  };
}
