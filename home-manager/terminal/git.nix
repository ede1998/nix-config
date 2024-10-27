{ ... }:
{
  programs.git = {
    enable = true;
    diff-so-fancy.enable = true;
    userName = "ede1998";
    userEmail = "online@erik-hennig.me";
    signing = {
      signByDefault = true;
      key = "A20FCA290932675D";
    };
    aliases = {
      restore = "!f() { git checkout $(git rev-list -n 1 HEAD -- $1)~1 -- $(git diff --name-status $(git rev-list -n 1 HEAD -- $1)~1 | grep ^D | cut -f 2); }; f";
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
          insteadOf = "https://github.com";
        };
      };
    };
  };
}
