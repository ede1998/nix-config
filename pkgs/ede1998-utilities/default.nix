{ pkgs }:
with pkgs;
let
  shellApp' =
    extraArgs: name: runtimeInputs:
    writeShellApplication (
      {
        inherit name runtimeInputs;

        text = builtins.readFile ./${name};
      }
      // extraArgs
    );
  shellApp = shellApp' { };
  apps = [
    (shellApp "yopenany" [
      coreutils
      findutils
      xdg-utils
      # kdePackages.kde-cli-tools optionally required by xdg-open
    ])
    (shellApp "yrename-no-spaces" [
      coreutils
      findutils
      gnused
    ])
    (shellApp' { bashOptions = [ "nounset" ]; } "yrename-pictures" [
      coreutils
      exif
      findutils
      gnugrep
      gnused
    ])
  ];
in
pkgs.symlinkJoin {
  name = "ede1998-utilities";
  paths = apps;
}
