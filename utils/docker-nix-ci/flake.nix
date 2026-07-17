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
    nix-fast-build = {
      url = "github:Mic92/nix-fast-build";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nix,
      nixpkgs,
      nix-fast-build,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      buildImageWithNix = import ("${nix.outPath}" + "/docker.nix");

      fakeSudo = pkgs.writeShellScriptBin "sudo" ''
        "$@"
      '';

      formatDate =
        d: "${builtins.substring 0 4 d}-${builtins.substring 4 2 d}-${builtins.substring 6 2 d}";
      formatTime =
        t: "${builtins.substring 8 2 t}-${builtins.substring 10 2 t}-${builtins.substring 12 2 t}";
      formatDateTime = dt: "${formatDate dt}T${formatTime dt}";
    in
    {
      formatter.${system} = pkgs.treefmt;

      packages.${system} = rec {
        default = container;
        container = buildImageWithNix {
          name = "codeberg.org/ede1998/nix-config/ci";
          tag = "latest";

          Labels = {
            "org.opencontainers.image.title" = "ede1998's Nix CI";
            "org.opencontainers.image.source" =
              "https://codeberg.org/ede1998/nix-config/src/branch/master/utils/docker-nix-ci/flake.nix";
            "org.opencontainers.image.vendor" = "ede1998";
            "org.opencontainers.image.version" = formatDateTime self.lastModifiedDate;
            "org.opencontainers.image.description" =
              "Used to build ede1998's NixOS configuration in CI. Based on official nix-os/nix image.";
          };

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
            attic-client
            findutils
            gnugrep
            jq
            nix-fast-build.packages.${system}.default
            nixfmt
            nodejs-slim
            treefmt
            xz
          ];
        };
      };
    };
}
