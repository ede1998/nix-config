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
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "patrickkfkan";
    repo = "patreon-dl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-t5eyLXCrzz6AxuIMvD2xEkDBbM1x7v6VJUWNQ98VEx4=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    ffmpeg
  ];

  npmDepsHash = "sha256-k6RYrdvPzVpCHGZj0bQ7Fg2pxSaZUkOxOVORFNPp/Z8=";

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
