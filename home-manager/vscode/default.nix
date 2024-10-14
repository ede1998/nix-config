{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = (
      pkgs.vscodium
      # stable version is a bit older and some extensions are not compatible
      #pkgs.unstable.vscodium
    );
    mutableExtensionsDir = false;
    # overlay is under `vscode-marketplace`
    # usual extensions are under `vscode-extensions`
    extensions = with pkgs.vscode-marketplace; [
      arrterian.nix-env-selector
      eamodio.gitlens
      fardolieri.close-tabs-via-regex
      james-yu.latex-workshop
      jnoortheen.nix-ide
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
    userSettings = {
      "window.autoDetectColorScheme" = true;
      "diffEditor.ignoreTrimWhitespace" = false;
      "diffEditor.renderSideBySide" = false;
      "terminal.integrated.stickyScroll.enabled" = true;

      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nil";
      "nix.serverSettings".nil.formatting.command = [ "nixfmt" ];

      "editor.inlayHints.enabled" = "offUnlessPressed"; # CTRL + ALT to enable/disable
      "editor.minimap.enabled" = false;

      "vim.normalModeKeyBindings" = [
        {
          before = [ "ctrl+p" ];
          commands = [ "workbench.action.quickOpen" ];
          silent = true;
        }
      ];

      "rust-analyzer.check.command" = "clippy";
      "rust-analyzer.interpret.tests" = true;
      "rust-analyzer.completion.snippets.custom" = import ./rust-analyzer-snippets.nix;

      "cSpell.userWords" = import ./vscode-spelling.nix;
    };
  };
  home.packages = [
    pkgs.nil # language server for nix
    pkgs.nixfmt-rfc-style
  ];
}
