{ config, lib, pkgs, initial-files, ... }:
with lib;
let
  cfg = config.initial-config.bitwarden-desktop;
in {
  # Cannot import here and in home.nix. Error:
  # The option `initial-files.file' in `home.nix' is already declared in initial-files.nix
  # As it is already imported in home.nix, it is passed down to here as function arg.
  # imports = [ import ../initial-files.nix ];

  options.initial-config.bitwarden-desktop = {
    enable = mkEnableOption "Bitwarden";
    email = mkOption {
        type = types.str;
        example = "my-mail@example.com";
        description = "The mail to pre-fill in the bitwarden application";
        default = "";
    };
    theme = mkOption {
        type = types.enum [ "dark" "light" "system" ];
        example = "dark"; # not sure if those values exist.
        description = "The color theme the GUI should follow.";
        default = "system";
    };
  };
 
  config = mkIf cfg.enable {
   home.packages = [ pkgs.bitwarden-desktop ];
   initial-files.file."${config.xdg.configHome}/Bitwarden/data.json" = {
      text = builtins.toJSON {
        stateVersion = 48;
        global = {
          theme = cfg.theme;
          rememberedEmail = cfg.email;
        };
      };
    };
  };
}