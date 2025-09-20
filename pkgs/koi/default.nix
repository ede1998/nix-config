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
  version = "0.6";

  src = fetchFromGitHub {
    owner = "baduhai";
    repo = "Koi";
    rev = "${version}";
    sha256 = "sha256-YRbS+WZaK0gJxNTU0KKi122Sn2hVk8t0vFhYr91sGfY=";
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

  sourceRoot = "${src.name}/";

  meta = with lib; {
    description = "Scheduling LIGHT/DARK Theme Converter for the KDE Plasma Desktop";
    longDescription = ''
      Koi is a program designed to provide the KDE Plasma Desktop functionality to automatically switch between light and dark themes. Koi is under semi-active development, and while it is stable enough to use daily, expect bugs. Koi is designed to be used with Plasma, and while some features may function under different desktop environments, they are unlikely to work and untested.

      Features:

      - Toggle between light and dark presets based on time
      - Change Plasma style
      - Change Qt colour scheme
      - Change Icon theme
      - Change GTK theme
      - Change wallpaper
      - Hide application to system tray
      - Toggle between LIGHT/DARK themes by clicking mouse wheel
    '';
    homepage = "https://github.com/baduhai/Koi";
    license = licenses.lgpl3;
    platforms = platforms.linux;
  };
}
