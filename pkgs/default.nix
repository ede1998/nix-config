# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
# You can iteratively create them using 'nix develop .#example'
pkgs: {
  cura5 = pkgs.callPackage ./cura5 { };
  koi = pkgs.kdePackages.callPackage ./koi { };
  xerox-workcentre-6027 = pkgs.callPackage ./xerox-workcentre-6027 { };
}
