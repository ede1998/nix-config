{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscodium; # stable version is a bit older and some extensions are not compatible
    mutableExtensionsDir = false;
    # overlay is under `vscode-marketplace`
    # usual extensions are under `vscode-extensions`
    extensions = with pkgs.vscode-marketplace; [
      arrterian.nix-env-selector
      bbenoist.nix
      eamodio.gitlens
      fardolieri.close-tabs-via-regex
      james-yu.latex-workshop
      ms-python.python
      nvarner.typst-lsp
      rust-lang.rust-analyzer
      streetsidesoftware.code-spell-checker
      tamasfe.even-better-toml
      usernamehw.errorlens
      vscodevim.vim
    ];
    keybindings = [
      {
        key = "ctrl+alt+x";
        command = "close-tabs-via-regex.close";
        args = "\\("; # Close all tabs that contain an opening bracket
      }
    ];
    # TODO: add user settings, e.g. clippy instead of check
  };
}
