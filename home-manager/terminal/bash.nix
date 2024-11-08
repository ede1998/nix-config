{ pkgs, lib, ... }:
let
  # sudo showkey can print key codes if needed
  keys = {
    up = "\\e[A";
    down = "\\e[B";
    ctrl = "\\C-";
    alt = "\\e";
    ctrl-super = "\M-";
  };
  switchbranch = with pkgs; ''
    switchbranch () 
    { 
      local branch=$(${git}/bin/git branch | ${gnused}/bin/sed "s/^[* ] //");
      [ -z "$branch" ] && return;
      local branch="$branch"$'\n-';
      local branch=$(${fzf}/bin/fzf <<< "$branch");
      [ -z "$branch" ] || ${git}/bin/git checkout "$branch"
    }
    bind -x '"${keys.ctrl}b": "switchbranch"'
  '';
  catwitch = with pkgs; ''
    realwitch() {
      ${coreutils}/bin/realpath $(${which}/bin/which "$1");
    }

    catwitch() {
      ${coreutils}/bin/cat $(${which}/bin/which "$1");
    }
    batwitch() {
      ${bat}/bin/bat $(${which}/bin/which "$1");
    }

    complete -A command realwitch
    complete -A command catwitch
    complete -A command batwitch
  '';
  extra-completions = with pkgs; [
    # Adds zr,zrf,zri aliases because bash-completion only sources on demand when zellij<TAB> is typed
    "source ${zellij}/share/bash-completion/completions/zellij.bash"
  ];
in
{
  programs.bash = {
    enable = true;
    historyControl = [
      "erasedups"
      "ignorespace"
    ];
    shellOptions = [ "histappend" ];
    sessionVariables = {
      HISTTIMEFORMAT = "%F %T ";
    };
    initExtra = ''
      source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh";
      # connect to ssh-agent
      [ -e /run/user/$(id -u)/ssh-agent ] && export SSH_AUTH_SOCK=/run/user/$(id -u)/ssh-agent;

      ${switchbranch}
      ${catwitch}
      ${lib.concatStringsSep "\n" extra-completions}

      source "${pkgs.complete-alias}/bin/complete_alias"
      complete -F _complete_alias "''${!BASH_ALIASES[@]}"
    '';
  };
  programs.readline = {
    enable = true;

    bindings = {
      ${keys.up} = "history-search-backward";
      ${keys.down} = "history-search-forward";
      "${keys.alt}e" = "edit-and-execute-command";
    };
  };
}
