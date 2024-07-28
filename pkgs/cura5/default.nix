{
  appimageTools,
  fetchurl,
  pkgs,
  writeScriptBin,
}:
# Consume cura as AppImage as described in https://github.com/NixOS/nixpkgs/issues/186570#issuecomment-1627797219
let
  cura5 = appimageTools.wrapType2 rec {
    name = "cura5";
    version = "5.7.2";
    src = fetchurl {
      url = "https://github.com/Ultimaker/Cura/releases/download/${version}-RC2/UltiMaker-Cura-${version}-linux-X64.AppImage";
      hash = "sha256-XlTcCmIqcfTg8fxM2KDik66qjIKktWet+94lFIJWopY=";
    };
    extraPkgs = pkgs: [ ];
  };
in
writeScriptBin "cura" ''
  #! ${pkgs.bash}/bin/bash
  # AppImage version of Cura loses current working directory and treats all paths relative to $HOME.
  # So we convert each of the files passed as argument to an absolute path.
  # This fixes use cases like `cd /path/to/my/files; cura mymodel.stl anothermodel.stl`.
  args=()
  for a in "$@"; do
    if [ -e "$a" ]; then
      a="$(realpath "$a")"
    fi
    args+=("$a")
  done
  exec "${cura5}/bin/cura5" "''${args[@]}"
''
