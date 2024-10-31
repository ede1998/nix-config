{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bat
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
    dust
    ede1998-utilities
    exif
    fclones
    fd
    file
    freecad
    fzf
    gcc
    gimp
    git-crypt
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
    kdePackages.kdepim-addons
    kdePackages.krdc
    kdePackages.krfb
    libreoffice-fresh
    nix-tree
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
}
