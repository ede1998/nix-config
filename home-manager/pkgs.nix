{ pkgs, ... }:
{
  home.packages = with pkgs; [
    koi
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
    exif
    fclones
    fd
    file
    freecad
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
}
