# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  home = {
    username = "erik";
    homeDirectory = "/home/erik";
  };

  # Add stuff for your user as you see fit:
  # home.packages = with pkgs; [ steam ];

  programs.home-manager.enable = true;
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
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraConfig = ''
      " change leader to space
      let mapleader=" "

      " minimum cursor distance to top/bottom of file when scrolling
      set scrolloff=5

      " always show line numbers
      set number

      " allow use of mouse
      set mouse=a

      " indicate line wrap
      let &showbreak = '↪'

      " enable tab-completion
      set wildmenu
      " auto-complete to longest existing element, on second tab cycle through possible commands
      set wildmode=list:longest,full

      " ignore compiled files
      set wildignore=*.o,*~,*.pyc

      " ignore temporary file
      set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store

      " show line,position in file in bottom left corner
      set ruler

      " highlight syntax
      syntax enable

      " create shortcut for :noh
      noremap <leader>h :noh<CR>

      " create shortcut for formatting entire file and jump back to original position
      noremap <leader>= gg=G<C-O>

      " Press Esc for normal mode in terminal
      tnoremap <Esc> <C-\><C-n>

      au BufNewFile,BufRead *.txt,*.md,*.tex set complete+=kspell

      " set formatting program
      au FileType json   setlocal equalprg=python\ -m\ json.tool
      au FileType rust   setlocal equalprg=rustfmt
      "au FileType rust   setlocal foldmethod=syntax
      au FileType python setlocal equalprg=autopep8\ -aaaaaaa\ -

      " sort comma separated line of numbers
      "noremap <leader>s :s/.*/\=join(sort(split(submatch(0), '\s*,\s*'), 'N'), ', ')<CR>:noh<CR>

      " auto-indent lines
      set autoindent

      " always show signcolumns
      set signcolumn=yes
    '';
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
