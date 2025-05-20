# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
# You can iteratively create them using 'nix develop .#example'
pkgs: {
  cura5 = pkgs.callPackage ./cura5 { };
  ede1998-utilities = pkgs.callPackage ./ede1998-utilities { };
  koi = pkgs.kdePackages.callPackage ./koi { };
  patreon-dl = pkgs.callPackage ./patreon-dl { };
  xerox-workcentre-6027 = pkgs.callPackage ./xerox-workcentre-6027 { };
}
