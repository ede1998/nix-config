{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.initial-config.discord;
in
{
  # Cannot import here and in home.nix. Error:
  # The option `initial-files.file' in `home.nix' is already declared in initial-files.nix
  # As it is already imported in home.nix, it is passed down to here as function arg.
  # imports = [ ../initial-files.nix ];

  options.initial-config.discord = {
    enable = mkEnableOption "Discord";
    skip_host_update = mkOption {
      type = types.bool;
      description = ''
        Whether to check for update at start-up.
        Blocks discord from running if an update is available.
      '';
      default = true;
    };
    auto_start = mkOption {
      type = types.bool;
      description = "Whether to autostart discord.";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.discord ];
    initial-files.file."${config.xdg.configHome}/discord/settings.json" = {
      text = builtins.toJSON { SKIP_HOST_UPDATE = cfg.skip_host_update; };
    };
    home.file."${config.xdg.configHome}/autostart/discord.desktop" = {
      enable = cfg.auto_start;
      source = "${pkgs.discord}/share/applications/discord.desktop";
    };
  };
}
