{ ... }:
{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks.smartknx = {
      hostname = "smartknx.local";
      user = "pi";
      identityFile = "~/.ssh/id_rsa";
    };
    matchBlocks."github.com".identityFile = "~/.ssh/id_rsa";
  };
  services.ssh-agent.enable = true;

  home.file.".ssh" = {
    source = ../../secrets/ssh;
    recursive = true;
  };
}
