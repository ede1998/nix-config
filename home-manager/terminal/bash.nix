{ ... }:
let
  keys = {
    up = "\\e[A";
    down = "\\e[B";
  };
in
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
    bindings = {
      "${keys.up}" = "history-search-backward";
      "${keys.down}" = "history-search-forward";
    };
  };
}
