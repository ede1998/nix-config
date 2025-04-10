{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = (
      # pkgs.vscodium
      # stable version is a bit older and some extensions are not compatible
      pkgs.unstable.vscodium
    );
    mutableExtensionsDir = false;
    # overlay is under `vscode-marketplace`
    # usual extensions are under `vscode-extensions`
    extensions =
      (with pkgs.vscode-marketplace; [
        alefragnani.bookmarks
        arrterian.nix-env-selector
        barbosshack.crates-io
        eamodio.gitlens
        fardolieri.close-tabs-via-regex
        james-yu.latex-workshop
        jnoortheen.nix-ide
        ms-python.python
        myriad-dreamin.tinymist
        rust-lang.rust-analyzer
        streetsidesoftware.code-spell-checker
        tamasfe.even-better-toml
        usernamehw.errorlens
        vscodevim.vim
      ])
      ++ (with pkgs.vscode-extensions; [
        # This extension from vscode-marketplace does not work.
        ms-vsliveshare.vsliveshare
        vadimcn.vscode-lldb
      ]);
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
      "vim.handleKeys" = {
        # Don't override Search Symbol
        "<C-t>" = false;
        # Defaults:
        "<C-d>" = true;
        "<C-s>" = false;
        "<C-z>" = false;
      };

      "rust-analyzer.check.command" = "clippy";
      "rust-analyzer.interpret.tests" = true;
      "rust-analyzer.completion.snippets.custom" = import ./rust-analyzer-snippets.nix;

      "cSpell.userWords" = import ./vscode-spelling.nix;

      "liveshare.diagnosticLogging" = true;
      "liveshare.connectionMode" = "relay";

      "bookmarks.saveBookmarksInProject" = true;

      # Invoke the correct shell for VSCode integrated terminal:
      # https://www.reddit.com/r/NixOS/comments/ycde3d/vscode_terminal_not_working_properly
      "terminal.integrated.defaultProfile.linux" = "bash";
      "terminal.integrated.profiles.linux"."bash" = {
        "path" = "/run/current-system/sw/bin/bash";
        "icon" = "terminal-bash";
      };
    };
  };
  home.packages = [
    pkgs.nil # language server for nix
    pkgs.nixfmt-rfc-style
  ];
}
