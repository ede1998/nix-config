{
  lib,
  stdenv,
  fetchzip,
  rpmextract,
  unzip,
  cups,
}:
stdenv.mkDerivation rec {
  pname = "xerox-workcentre-6027";
  version = "1.0-21";

  src = fetchzip {
    url = "https://download.support.xerox.com/pub/drivers/WC6027/drivers/linux/pt_BR/Xerox-WorkCentre-6027-${version}.noarch.zip";
    sha256 = "kFQBuMN/uy2VSqso4GEvvuEaVckouXorE3yn9eBD2ZA=";
  };

  buildInputs = [
    unzip
    rpmextract
    cups
  ];

  installPhase = ''
    mkdir $out
    rpmextract Xerox-WorkCentre-6027-${version}.noarch.rpm
    mv usr/share $out/share
  '';

  meta = with lib; {
    description = "Xerox Workcentre 6027 CUPS driver";
    homepage = "https://www.support.xerox.com/en-us/product/workcentre-6027/downloads";
    platforms = platforms.all;
    license = licenses.unfree;
  };
}
