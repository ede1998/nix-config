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

  round-anything = pkgs.fetchFromGitHub {
    owner = "Irev-Dev";
    repo = "Round-Anything";
    rev = "061fef7c429628808e847696bb345a9b0ec6e279";
    sha256 = "sha256-xED5fz+VmVv4VJO72PQuExqOtxFdCQ4v4GA99GvA70E=";
  };
in
{
  home.packages = [ pkgs.openscad ];
  xdg.dataFile = {
    "${library-dir}/BOSL" = {
      source = bosl;
    };
    "${library-dir}/Round-Anything" = {
      source = round-anything;
    };
  };
}
