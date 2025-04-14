{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.initial-config.koi;
  to-bool = bool: if bool then 2 else 0;
  to-type =
    type: with type; {
      dark = dark;
      enabled = enable;
      light = light;
    };
  mk-type-option = name: example-dark: example-light: {
    enable = mkOption {
      type = types.bool;
      description = "Whether to also change ${name} on theme toggle";
      default = false;
    };
    dark = mkOption {
      type = types.str;
      description = "Which ${name} to use for dark theme";
      example = example-dark;
      default = "";
    };
    light = mkOption {
      type = types.str;
      description = "Which ${name} to use for light theme";
      example = example-light;
      default = "";
    };
  };

in
{
  # Cannot import here and in home.nix. Error:
  # The option `initial-files.file' in `home.nix' is already declared in initial-files.nix
  # As it is already imported in home.nix, it is passed down to here as function arg.
  # imports = [ ../initial-files.nix ];

  options.initial-config.koi = {
    enable = mkEnableOption "Koi";

    auto-start = mkOption {
      type = types.bool;
      description = "Whether to autostart Koi.";
      default = false;
    };

    force = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If true, always overwrite the configuration file when the generation is activated.
        This should be safe for Koi because the only non-managed state in this file is whether
        light or dark theme is currently active. This would be reverted to the value of `General.initial-theme`.
      '';
    };

    General = {
      initial-theme = mkOption {
        type = types.enum [
          "Dark"
          "Light"
        ];
        example = "Light";
        description = "The color theme that Koi should start with on first start";
        default = "Dark";
      };
      notify-on-swap = mkOption {
        type = types.bool;
        description = "Whether to show a notification when theme is toggled between light and dark";
        default = true;
      };
      start-hidden = mkOption {
        type = types.bool;
        description = "Whether to start Koi in the background or show the main window";
        default = true;
      };
      schedule = {
        enable = mkOption {
          type = types.bool;
          description = "Whether to automatically change theme based on the configured trigger type";
          default = false;
        };
        trigger = mkOption {
          type = types.enum [
            "time"
            "sun"
          ];
          description = "Whether to change the theme based on a time schedule or sunrise/sunset";
          default = "time";
        };

        time =
          let
            time-regex = "[[:digit:]]{2}:[[:digit:]]{2}:[[:digit:]]{2}";
            time-option =
              theme: example:
              mkOption {
                type = types.strMatching time-regex;
                example = example;
                description = "Time when to activate to ${theme} theme";
                default = "00:00:00";
              };
          in
          {
            dark = time-option "dark" "19:30:00";
            light = time-option "light" "08:15:00";
          };
        location =
          let
            location-option = mkOption {
              type = types.float;
              description = "Location for which to lookup sunrise/sunset time";
              default = 0.0;
            };
          in
          {
            latitude = location-option;
            longitude = location-option;
          };
      };

    };

    ColorScheme =
      mk-type-option "colors" "\${pkgs.kdePackages.breeze}/share/color-schemes/BreezeDark.colors"
        "\${pkgs.kdePackages.breeze}/share/color-schemes/BreezeLight.colors";
    GTKTheme = mk-type-option "gnome/GTK application style" "Breeze-Dark" "Breeze";
    IconTheme = mk-type-option "icon theme" "breeze-dark" "Breeze_Light";
    KvantumStyle = mk-type-option "kvantum style" "Fluent-Dark" "Fluent-Light";
    PlasmaStyle = mk-type-option "global theme" "breeze-dark" "breeze-light";
    Wallpaper =
      mk-type-option "wallpaper" "/path/to/wallpaper-dark.jpeg"
        "/path/to/wallpaper-light.jpeg";
  };

  config =
    let
      desktop-file = "${pkgs.koi}/share/applications/local.KoiDbusInterface.desktop";
    in
    mkIf cfg.enable {
      home.packages = [ pkgs.koi ];
      home.file."${config.xdg.configHome}/autostart/koi.desktop" = {
        enable = cfg.auto-start;
        source = desktop-file;
      };
      assertions = [
        {
          assertion = cfg.auto-start && builtins.pathExists desktop-file;
          message = "Failed to find desktop file to link for autostart: ${desktop-file}";
        }
      ];
      initial-files.file."${config.xdg.configHome}/koirc" = {
        force = cfg.force;
        text = generators.toINI { } {
          General = with cfg.General; {
            current = initial-theme;
            notify = to-bool notify-on-swap;
            start-hidden = to-bool start-hidden;
            schedule = to-bool schedule.enable;
            schedule-type = schedule.trigger;
            time-dark = schedule.time.dark;
            time-light = schedule.time.light;
            latitude = schedule.location.latitude;
            longitude = schedule.location.longitude;
          };

          ColorScheme = to-type cfg.ColorScheme;
          GTKTheme = to-type cfg.GTKTheme;
          IconTheme = to-type cfg.IconTheme;
          KvantumStyle = to-type cfg.KvantumStyle;
          PlasmaStyle = to-type cfg.PlasmaStyle;
          Wallpaper = to-type cfg.Wallpaper;
        };
      };
    };
}
