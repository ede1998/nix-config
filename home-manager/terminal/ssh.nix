{ secrets, pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      # default config
      "*" = {
        addKeysToAgent = "yes";
        forwardAgent = false;
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };
      smartknx = {
        hostname = "192.168.140.44";
        user = "pi";
        identityFile = "~/.ssh/id_rsa";
      };
      qnap-nas = {
        hostname = "192.168.140.100";
        user = "admin";
        identityFile = "~/.ssh/id_rsa";
      };
      z3 = {
        hostname = "z3.local";
        user = "buffalo";
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
    pinentry.package = pkgs.pinentry-curses;
  };

  home.file.".ssh" = {
    source = "${secrets}/ssh";
    recursive = true;
  };
}
