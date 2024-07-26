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
    outputs.homeManagerModules.initial-files

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default
    inputs.plasma-manager.homeManagerModules.plasma-manager

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
      inputs.nix-vscode-extensions.overlays.default

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
    sessionVariables = {
      VISUAL = "${pkgs.neovim}/bin/nvim";
      EDITOR = "${pkgs.neovim}/bin/nvim";
    };
    shellAliases = {
    # for simple aliases that are cross-shell compatible
      code = "codium";
    };
  };

  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    koi
    bat
    bitwarden-desktop
    blender
    cargo-asm
    cargo-binutils
    cargo-bloat
    cargo-edit
    cargo-espmonitor
    cargo-expand
    cargo-outdated
    cargo-udeps
    cargo-update
    cura5
    dig
    direnv
    discord # If not already there, add the following to ~/.config/discord/settings.json: { "SKIP_HOST_UPDATE": true }
    dust
    exif
    fclones
    fd
    file
    freecad
    gcc
    gimp
    glxinfo
    gnumake
    htop
    hunspell
    hunspellDicts.de_DE
    hunspellDicts.en_US
    inkscape
    inxi
    jq
    jqp
    kdePackages.filelight
    kdePackages.kcalc
    kdePackages.kdeconnect-kde
    kdePackages.krdc
    kdePackages.krfb
    libreoffice-fresh
    p7zip
    pciutils
    pdfarranger
    pdfpc
    pinentry
    piper
    psmisc
    ripgrep
    rm-improved
    rust-script
    rustup
    texliveFull
    tldr
    traceroute
    tree
    typst
    ungoogled-chromium
    unstable.espup
    unstable.gnucash
    unstable.ocrmypdf
    unzip
    ventoy-full
    viu
    vlc
    wireshark
    wl-clipboard-rs
    xmlstarlet
    xsv
    zip
  ];

  programs.home-manager.enable = true;
  programs.bash = {
    enable = true;
    initExtra = ''
      source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    '';
  };
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
  programs.plasma = {
    enable = true;
    overrideConfig = true;
    # Run rc2nix tool to see current config formatted as nix: `nix run github:nix-community/plasma-manager`

    # Some high-level settings:
    workspace = {
      clickItemTo = "select";
      lookAndFeel = "org.kde.breezedark.desktop";
      #cursor.theme = "Bibata-Modern-Ice";
      #iconTheme = "Papirus-Dark";
      #wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Patak/contents/images/1080x1920.png";
    };

    #hotkeys.commands."launch-konsole" = {
    #  name = "Launch Konsole";
    #  key = "Meta+Alt+K";
    #  command = "konsole";
    #};

    panels = [
      # Windows-like panel at the top
      {
        location = "top";
	screen = 2;
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.icontasks"
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
        ];
      }
      # Global menu at the top
      # {
      #   location = "top";
      #   height = 26;
      #   widgets = [
      #     "org.kde.plasma.appmenu"
      #   ];
      # }
    ];

    # Some mid-level settings:
    shortcuts = {
      #ksmserver = {
      #  "Lock Session" = [ "Screensaver" "Meta+Ctrl+Alt+L" ];
      #};

      kwin = {
        "Switch Window Down" = "Meta+J";
        "Switch Window Left" = "Meta+H";
        "Switch Window Right" = "Meta+L";
        "Switch Window Up" = "Meta+K";
      };
    };

    kwin = {
      titlebarButtons.left = ["on-all-desktops" "keep-above-windows" "application-menu"];
      virtualDesktops = {
        number = 4;
	rows = 4;
      };
    };

    # Some low-level settings:
    configFile = {
      "baloofilerc"."Basic Settings"."Indexing-Enabled" = false;
      "kwinrc" = {
        # Forces kde to not change this value (even through the settings app).
        "Desktops"."Number".immutable = true;
        # Disable effects when cursor is on screen edge
        # Source: https://www.reddit.com/r/kde/comments/r5xir0/comment/hoehzhq
        "Effect-overview".BorderActivate = 9;
      };
    };
  };
  programs.konsole = {
    enable = true;
    extraConfig = {
      MainWindow.MenuBar = false;
    };

  };
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscodium; # stable version is a bit older and some extensions are not compatible
    mutableExtensionsDir = false;
    # overlay is under `vscode-marketplace`
    # usual extensions are under `vscode-extensions`
    extensions = with pkgs.vscode-marketplace; [
        arrterian.nix-env-selector
        bbenoist.nix
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

  services.gpg-agent = {
    enable = true;
    enableBashIntegration = true;
    defaultCacheTtl = 3600;
    maxCacheTtl = 999999;
    pinentryPackage = pkgs.pinentry;
  };

  #xdg = {
  #  enable = true;
  #
  # Cura config does not work well, program seems to ignore it when it's write-only
  #  dataFile."cura" = {
  #    source = ./cura/.local/share;
  #    recursive = true;
  #  };
  #  configFile."cura".source = ./cura/.config;
  #};

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
