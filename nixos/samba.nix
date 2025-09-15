{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [ kdePackages.kdenetwork-filesharing ];
  services.samba = {
    enable = true;
    openFirewall = true;
    settings.global.security = "user";
    usershares.enable = true;
  };
}
