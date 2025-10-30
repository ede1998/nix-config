{ pkgs, ... }:
let
  dev-tools = with pkgs; [
    #ventoy-full # disabled because I'm not using it at the moment and there is some discussion: https://github.com/NixOS/nixpkgs/issues/404663
    cargo-binutils
    cargo-bloat
    cargo-edit
    cargo-espmonitor
    cargo-expand
    cargo-outdated
    cargo-show-asm
    cargo-udeps
    cargo-update
    gcc
    git-crypt
    gnumake
    rust-script
    rustup
    unstable.espup
    wireshark
  ];
  cli-tools = with pkgs; [
    bat
    dig
    dust
    ede1998-utilities
    exif
    unstable.fclones
    fd
    file
    htop
    inxi
    jq
    jqp
    nix-tree
    p7zip
    patreon-dl
    pciutils
    pinentry
    poppler_utils
    psmisc
    ripgrep
    tldr
    traceroute
    tree
    unstable.ocrmypdf
    unstable.rip2
    unzip
    viu
    xan
    xmlstarlet
    yq
    zip
  ];
in
{
  home.packages =
    dev-tools
    ++ cli-tools
    ++ (with pkgs; [
      blender
      cura5
      element-desktop
      gimp
      hunspell
      hunspellDicts.de_DE
      hunspellDicts.en_US
      inkscape
      kdePackages.filelight
      kdePackages.kcalc
      kdePackages.kdepim-addons
      kdePackages.krdc
      kdePackages.krfb
      (unstable.kgeotag.overrideAttrs (
        super: self: {
          postInstall = ''
            mkdir -p $out/share/kxmlgui5/kgeotag
            install -Dm644 $srcs/kgeotagui.rc $out/share/kxmlgui5/kgeotag/kgeotagui.rc
          '';
        }
      ))
      libreoffice-fresh
      pdfarranger
      pdfpc
      texliveFull
      typst
      ungoogled-chromium
      unstable.fluffychat
      (unstable.identity.overrideAttrs (super: self: { meta.priority = 1; })) # fix collision with mesa-demos
      vlc
      wl-clipboard-rs
    ]);
}
