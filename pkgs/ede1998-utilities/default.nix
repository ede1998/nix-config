{ pkgs }:
with pkgs;
let
  shellApp =
    { name, ... }@args: writeShellApplication ({ text = builtins.readFile ./${name}; } // args);
  apps = [
    (shellApp {
      name = "yopenany";
      runtimeInputs = [
        coreutils
        findutils
        xdg-utils
        # kdePackages.kde-cli-tools optionally required by xdg-open
      ];
    })
    (shellApp {
      name = "yrename-no-spaces";
      runtimeInputs = [
        coreutils
        findutils
        gnused
      ];
    })
    (shellApp {
      name = "yrename-pictures";
      bashOptions = [ "nounset" ];
      runtimeInputs = [
        coreutils
        exif
        findutils
        gnugrep
        gnused
      ];
    })
    (shellApp {
      name = "ygetscans";
      runtimeInputs = [
        coreutils
        fd
        fzf
        gnused
        libreoffice-fresh
        ocrmypdf
        rm-improved
        xdg-utils
        # kdePackages.kde-cli-tools optionally required by xdg-open
      ];
    })
    (shellApp {
      name = "ypreparebanking";
      bashOptions = [
        "nounset"
        "pipefail"
      ];
      runtimeInputs = [
        coreutils
        findutils
        fzf
        gawk
        gnused
        iconv
        libreoffice-fresh
      ];
    })
    (shellApp {
      name = "yrename-by-last-modified";
      runtimeInputs = [
        coreutils
        gnused
      ];
    })
    (shellApp {
      name = "yfile-pictures";
      runtimeInputs = [
        coreutils
        fd
      ];
    })
  ];
in
pkgs.symlinkJoin {
  name = "ede1998-utilities";
  paths = apps;
}
