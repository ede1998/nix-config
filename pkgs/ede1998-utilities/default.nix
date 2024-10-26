{ pkgs }:
with pkgs;
let
  yopenany = writeShellApplication {
    name = "yopenany";
    runtimeInputs = [
      findutils
      coreutils
      xdg-utils
    ];
    text = builtins.readFile ./yopenany;
  };
in
pkgs.symlinkJoin {
  name = "ede1998-utilities";
  paths = [ yopenany ];
}
