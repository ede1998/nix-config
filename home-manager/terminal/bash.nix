{ ... }:
{
  programs.bash = {
    enable = true;
    historyControl = [
      "erasedups"
      "ignorespace"
    ];
    initExtra = ''
      source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh";
      # connect to ssh-agent
      [ -e /run/user/$(id -u)/ssh-agent ] && export SSH_AUTH_SOCK=/run/user/$(id -u)/ssh-agent;
    '';
  };
  programs.readline = {
    enable = true;
    extraConfig = ''
      # alternate mappings for "page up" and "page down" to search the history
      "\e[5~": history-search-backward
      "\e[6~": history-search-forward
    '';
  };
}
