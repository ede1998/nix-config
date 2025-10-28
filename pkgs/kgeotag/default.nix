{
  stdenv,
  cmake,
  fetchFromGitLab,
  lib,
  kdePackages,
  qt6,
}:
let
  marble = kdePackages.marble.overrideAttrs (
    finalAttrs: previousAttrs: {
      # breaks with split outputs
      # FIXME: track this down
      outputs = [ "out" ];
    }
  );
in
stdenv.mkDerivation {
  pname = "kgeotag";
  version = "1.8.0-unstable-2025-10-25";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    repo = "kgeotag";
    owner = "graphics";
    rev = "1f09ed355771c7e2ec7c2c50640cbc5e4047a1be";
    hash = "sha256-nCxDoAateWLPZawYXrdvxrhh50Y20WVmK7SIfGVNTyU=";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    kdePackages.libkexiv2
    marble
    qt6.qtwebengine
  ];

  postInstall = ''
    mkdir -p $out/share/kxmlgui5/kgeotag
    install -Dm644 $srcs/kgeotagui.rc $out/share/kxmlgui5/kgeotag/kgeotagui.rc
  '';

  meta = with lib; {
    homepage = "https://kgeotag.kde.org/";
    description = "Stand-alone photo geotagging program";
    changelog = "https://invent.kde.org/graphics/kgeotag/-/blob/master/CHANGELOG.rst";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ cimm ];
    mainProgram = "kgeotag";
  };
}
