{
  imports = [
    ./bash.nix
    #./blesh.nix # disable blesh: missing option exec_exit_mark because no new release, trouble with CTRL+C and tab completion left-overs
    ./direnv.nix
    ./fzf.nix
    ./git.nix
    ./konsole.nix
    ./navi
    ./neovim.nix
    ./ssh.nix
    ./starship.nix
    ./zellij.nix
    ./zoxide.nix
  ];
}
