# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  cura5 = pkgs.callPackage ./cura5 { };
  koi = pkgs.kdePackages.callPackage ./koi { };
}
