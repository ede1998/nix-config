{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  qtbase,
  wrapQtAppsHook,
  kcoreaddons,
  kwidgetsaddons,
  kconfig,
}:

stdenv.mkDerivation rec {
  pname = "koi";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "baduhai";
    repo = "Koi";
    rev = "${version}";
    sha256 = "sha256-dhpuKIY/Xi62hzJlnVCIOF0k6uoQ3zH129fLq/r+Kmg=";
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
