{
  system ? builtins.currentSystem,
  overlays ? [ ],
}:
let
  nixpkgs-unstable = import <nixpkgs-unstable>;
  base-overlays = import ../overlays {
    inputs = {
      inherit nixpkgs-unstable;
    };
  };
in
import <nixpkgs> {
  overlays = overlays ++ (builtins.attrValues base-overlays);
  inherit system;
}
