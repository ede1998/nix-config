{
  lib,
  config,
  pkgs,
  ...
}:
let
  gitVersionAtLeast =
    minimum-version:
    (builtins.compareVersions config.programs.git.package.version minimum-version) >= 0;
in
{
  home.packages = [ pkgs.pre-commit ];
  programs.git = {
    enable = true;
    diff-so-fancy.enable = true;
    userName = "ede1998";
    userEmail = "online@erik-hennig.me";
    signing = {
      signByDefault = true;
      key = "A20FCA290932675D";
    };
    lfs.enable = true;
    aliases = {
      restore = "!f() { git checkout $(git rev-list -n 1 HEAD -- $1)~1 -- $(git diff --name-status $(git rev-list -n 1 HEAD -- $1)~1 | grep ^D | cut -f 2); }; f";
      fix-commit = "commit --edit --file=.git/COMMIT_EDITMSG";
      co = "checkout";
      br = "branch";
      r = "reset";
      unstage = "reset HEAD --";
      cp = "cherry-pick";
      # log {{{
      last = "log -1 HEAD";
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      ll = "log --pretty=format:'%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [a:%an,c:%cn]' --decorate --numstat";
      # }}}
      # stash {{{
      sl = "stash list";
      sa = "stash apply";
      ss = "stash save";
      # }}}
      #list remotes
      rem = "!git config -l | grep remote.*url | tail -n +2";
      list-aliases = "!git config -l | grep alias | cut -c 7-";
      # undo from here http://megakemp.com/2016/08/25/git-undo/
      undo = "!f() { git reset --hard $(git rev-parse --abbrev-ref HEAD)@{\${1-1}}; }; f";
    };
    ignores = [
      ".vscode/"
      "_wip/"
      "__pycache__/"
      ".direnv/"
    ];
    extraConfig = {
      credential.helper = "store --file ~/.config/git/credentials";
      url = {
        "ssh://git@github.com" = {
          pushInsteadOf = "https://github.com";
        };
      };
      rerere.enabled = true;
      branch.sort = "-committerdate";
      push.useForceIfIncludes = true;
      fetch.prune = true;
    }
    // lib.optionalAttrs (gitVersionAtLeast "2.37.0") { push.autoSetupRemote = true; };
  };
}
