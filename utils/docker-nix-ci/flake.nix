{
  description = "Used to build a docker container for CI in this repo.";
  # The flake is based on the idea to use nixos/nix builder function described here:
  # https://discourse.nixos.org/t/how-to-build-a-docker-image-with-a-working-nix-inside-it/32960/5

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nix = {
      url = "github:NixOS/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nix,
      nixpkgs,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      buildImageWithNix = import ("${nix.outPath}" + "/docker.nix");

      fakeSudo = pkgs.writeShellScriptBin "sudo" ''
        "$@"
      '';

    in
    {
      formatter.${system} = pkgs.treefmt;

      packages.${system} = rec {
        default = container;
        container = buildImageWithNix {
          name = "codeberg.org/ede1998/nix-config/ci";
          tag = "latest";

          nixConf = {
            experimental-features = [
              "nix-command"
              "flakes"
            ];
          };

          bundleNixpkgs = false;

          inherit pkgs;
          extraPkgs = with pkgs; [
            fakeSudo
            jq
            findutils
            gnugrep
            nodejs-slim
            xz
          ];
        };
      };
    };
}
