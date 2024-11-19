{
  appimageTools,
  fetchurl,
  pkgs,
  lib,
  writeScript,
}:
let
  pname = "cura5";
  version = "5.8.1";
  repo = "UltiMaker/Cura";
  src = fetchurl {
    url = "https://github.com/${repo}/releases/download/${version}/UltiMaker-Cura-${version}-linux-X64.AppImage";
    hash = "sha256-VLd+V00LhRZYplZbKkEp4DXsqAhA9WLQhF933QAZRX0=";
  };
  appimage-contents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;
  extraPkgs = pkgs: [ pkgs.bash ];
  extraInstallCommands =
    let
      # Consume cura as AppImage as described in https://github.com/NixOS/nixpkgs/issues/186570#issuecomment-1627797219
      script = ''
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
        exec "$out/bin/cura5" "''${args[@]}"
      '';
    in
    ''
      install -m 444 -D ${appimage-contents}/cura-icon.png -t $out/share/pixmaps

      install -m 444 -D ${appimage-contents}/com.ultimaker.cura.desktop -t $out/share/applications

      substituteInPlace $out/share/applications/com.ultimaker.cura.desktop \
        --replace-fail 'Exec=UltiMaker-Cura' 'Exec=cura'

      cat > $out/bin/cura << EOF
      ${script}
      EOF

      chmod +x "$out/bin/cura"
    '';

  passthru.custom.newVersionCheck = writeScript "versionCheck.sh" (
    with pkgs;
    ''
      ${curl}/bin/curl --silent -L -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        'https://api.github.com/repos/${repo}/releases/latest' |
        ${jq}/bin/jq '.tag_name' --raw-output
    ''
  );

  meta = with lib; {
    description = "State-of-the-art slicer app to prepare your 3D models for your 3D printer.";
    mainProgram = "cura";
    homepage = "https://ultimaker.com/de/software/ultimaker-cura";
    license = licenses.mit;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
  };
}
