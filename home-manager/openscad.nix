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

  bosl2 = pkgs.fetchFromGitHub {
    owner = "BelfrySCAD";
    repo = "BOSL2";
    rev = "v2.0.741";
    sha256 = "sha256-0qy9WX7lhiVoY5Jv5pdXHOMXf6QfnrEJ5XHzv5B2Skk=";
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
    "${library-dir}/BOSL2" = {
      source = bosl2;
    };
    "${library-dir}/Round-Anything" = {
      source = round-anything;
    };
  };
}
