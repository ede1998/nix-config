{ pkgs }:
with pkgs;
let
  shellApp =
    name: runtimeInputs:
    writeShellApplication {
      inherit name runtimeInputs;
      text = builtins.readFile ./${name};
    };
  apps = [
    (shellApp "yopenany" [
      coreutils
      findutils
      xdg-utils
    ])
    (shellApp "yrename-no-spaces" [
      coreutils
      findutils
      gnused
    ])
  ];
in
pkgs.symlinkJoin {
  name = "ede1998-utilities";
  paths = apps;
}
