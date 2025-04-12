{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  wrapQtAppsHook,
  kcoreaddons,
  kwidgetsaddons,
  kconfig,
}:

stdenv.mkDerivation rec {
  pname = "koi";
  version = "0.5";

  src = fetchFromGitHub {
    owner = "baduhai";
    repo = "Koi";
    rev = "${version}";
    sha256 = "sha256-prkxFZW1F/I5jOOV5fZryHCYBSWAlGwH5afNEjKd2Ek=";
  };

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook
  ];

  buildInputs = [
    kcoreaddons
    kwidgetsaddons
    kconfig
  ];

  sourceRoot = "source/src";

  meta = with lib; {
    description = "Theme scheduling for the KDE Plasma Desktop";
    homepage = "https://github.com/baduhai/Koi";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
