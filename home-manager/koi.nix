{ pkgs, ... }:
{
  initial-config.koi = {
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
}
