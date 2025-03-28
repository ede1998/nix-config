{ lib, config, ... }:
let
  keys = {
    ctrl = "\\C-";
  };
  fzf-options = [
    # Escaping madness. We need to escape the quotes for nix, the dollar
    # and the backslashes for bash and also the tab character between the quotes
    # should stay a tab character so take care. Some editor might inadvertantly
    # transform it to a space.
    "--preview 'tree -C \\$(cut -d \\\"	\\\" -f 2 <<< {}) | head -n 200'"
    "--height=50%"
    "--layout=reverse"
    # Location for number of matches
    "--info=inline"
    "--cycle"
    # Hide start of long lines instead of end
    "--keep-right"
    # Searching behavior
    "--exact"
    "--no-sort"
    "--scheme=path"
    "--exit-0"
    # expand tilde
    "--bind='~:put(${config.home.homeDirectory}),ctrl-t:put(~)'"
    "--color header:italic"
    "--header 'CTRL-T to type ~ verbatim'"
  ];
in
{
  programs.zoxide.enable = true;
  programs.bash.initExtra = ''
    export _ZO_FZF_OPTS="${lib.concatStringsSep " " fzf-options}";
    bind '"${keys.ctrl}a": "${keys.ctrl}uzi\n"'
  '';
}
