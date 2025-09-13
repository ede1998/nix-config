{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [ kdePackages.kdenetwork-filesharing ];
  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    usershares.enable = true;
  };
}
