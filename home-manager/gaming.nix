{ config, pkgs, ... }:
{
  initial-config.discord = {
    enable = true;
    auto_start = true;
  };
  home.file."${config.xdg.configHome}/autostart/steam.desktop".source = "${pkgs.steam}/share/applications/steam.desktop";
}
