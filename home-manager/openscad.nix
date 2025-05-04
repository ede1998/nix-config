{
  pkgs,
  ...
}:
let
  library-dir = "OpenSCAD/libraries";
  bosl = pkgs.fetchFromGitHub {
    owner = "revarbat";
    repo = "BOSL";
    rev = "v1.0.3";
    sha256 = "sha256-FHHZ5MnOWbWnLIL2+d5VJoYAto4/GshK8S0DU3Bx7O8=";
  };
in
{
  home.packages = [ pkgs.unstable.openscad-unstable ];
  xdg.dataFile."${library-dir}/BOSL" = {
    source = bosl;
  };
}
