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
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "patrickkfkan";
    repo = "patreon-dl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nM5VoWZaezJqtEvhYevdxFk60we4cnddFSVR3dx1tNU=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    ffmpeg
  ];

  env.PUPPETEER_SKIP_DOWNLOAD = true;

  npmDepsHash = "sha256-Wk+o+Rkc6qPRWmzP6cbEFXNOfmtqzfFY5CGV33QyXhQ=";

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
