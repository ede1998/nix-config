# { pkgs ? import <nixpkgs> {} }:
#
# let
#   NPM_CONFIG_PREFIX = toString ./npm_config_prefix;
# in pkgs.mkShell {
#   packages = with pkgs; [
#     nodejs_23
#     nodePackages.npm
#     ffmpeg
#   ];
#
#   shellHook = ''
#     export PATH="${NPM_CONFIG_PREFIX}/bin:$PATH"
#   '';
# }
{
  buildNpmPackage,
  fetchFromGitHub,
  ffmpeg,
  lib,
  makeWrapper,
}:
buildNpmPackage (finalAttrs: {
  pname = "patreon-dl";
  version = "3.3.1";

  src = fetchFromGitHub {
    owner = "patrickkfkan";
    repo = "patreon-dl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9mBaQX51T41UW+RM3KXaof6AtnNmszBsOLcbLyvFtI0=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    ffmpeg
  ];

  env.PUPPETEER_SKIP_DOWNLOAD = true;

  npmDepsHash = "sha256-o4H6B8JqmB8J3JJ3Rjg0wNxWoCkmwxyC+Ork+DtBxXQ=";

  # The prepack script runs the build script, which we'd rather do in the build phase.
  npmPackFlags = [ "--ignore-scripts" ];

  postFixup = ''
    wrapProgram $out/bin/patreon-dl \
      --set PATH ${lib.makeBinPath [ ffmpeg ]}
  '';

  meta = {
    description = "A Patreon downloader written in Node.js.";
    homepage = "https://github.com/patrickkfkan/patreon-dl";
  };
})
