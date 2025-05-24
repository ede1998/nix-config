{ secrets, pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      smartknx = {
        hostname = "smartknx.local";
        user = "pi";
        identityFile = "~/.ssh/id_rsa";
      };
      qnap-nas = {
        hostname = "qnap-nas.local";
        user = "admin";
        identityFile = "~/.ssh/id_rsa";
      };
      "github.com".identityFile = "~/.ssh/id_rsa";
    };
  };

  services.ssh-agent.enable = true;
  services.gpg-agent = {
    enable = true;
    enableBashIntegration = true;
    defaultCacheTtl = 3600;
    maxCacheTtl = 999999;
    pinentry.package = pkgs.pinentry;
  };

  home.file.".ssh" = {
    source = "${secrets}/ssh";
    recursive = true;
  };
}
