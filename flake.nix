{
  description = "Erik's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nextcloud-tag-sync = {
      url = "github:ede1998/nextcloud-tag-sync";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      # Supported systems for your flake packages, shell, etc.
      systems = [
        "aarch64-linux"
        #"i686-linux"
        "x86_64-linux"
        #"aarch64-darwin"
        #"x86_64-darwin"
      ];
      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Source: https://github.com/NixOS/nix/issues/4329#issuecomment-740787749
      isDecrypted =
        test-file:
        with nixpkgs.lib;
        hasInfix "text" (
          fileContents (
            with nixpkgs.legacyPackages.x86_64-linux;
            runCommandNoCCLocal "chk-encryption" {
              buildInputs = [ file ];
              src = test-file;
            } "file $src > $out"
          )
        );
      throwIfGitCryptNotInitialized = nixpkgs.lib.warnIfNot (isDecrypted ./secrets/hello-world.txt) warning-git-crypt;
      warning-git-crypt = ''
        Please add your decryption key to git-crypt.
        Otherwise, programs will receive encrypted configuration.
        Command:
        wl-paste | base64 -d | git crypt unlock -
      '';

      nixpkgsUnfree =
        system:
        (import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        });

      nixosConfigurations' = secrets: {
        larc = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs secrets;
          };
          modules = [ ./nixos/larc/configuration.nix ];
        };
        babbage = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs secrets;
          };
          modules = [ ./nixos/babbage/configuration.nix ];
        };
      };
      homeConfigurations' =
        secrets:
        let
          config' =
            user-at-hostName:
            let
              hostName = nixpkgs.lib.last (nixpkgs.lib.splitString "@" user-at-hostName);
            in
            home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
              extraSpecialArgs = {
                inherit
                  inputs
                  outputs
                  secrets
                  hostName
                  ;
              };
              modules = [
                # > Our main home-manager configuration file <
                ./home-manager/${hostName}.nix
              ];
            };
        in
        nixpkgs.lib.genAttrs [
          "erik@babbage"
          "erik@larc"
        ] config';
    in
    {
      checks = forAllSystems (
        system:
        let
          home-configurations = homeConfigurations' ./secrets-dummy;
          nixos-configurations = nixosConfigurations' ./secrets-dummy;
        in
        nixpkgs.lib.genAttrs (builtins.attrNames home-configurations) (
          home-config: home-configurations.${home-config}.activationPackage
        )
        // nixpkgs.lib.genAttrs (builtins.attrNames nixos-configurations) (
          nixos-config: nixos-configurations.${nixos-config}.config.system.build.toplevel
        )
      );
      # Your custom packages
      # Accessible through 'nix build', 'nix shell', etc
      packages = forAllSystems (system: import ./pkgs (nixpkgsUnfree system));
      # Make `nix develop` possible
      devShells = forAllSystems (system: import ./shell.nix nixpkgs.legacyPackages.${system});
      # Formatter for your nix files, available through 'nix fmt'
      # Other options beside 'alejandra' include 'nixpkgs-fmt'
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.treefmt);

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };
      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules = import ./modules/nixos;
      # Reusable home-manager modules you might want to export
      # These are usually stuff you would upstream into home-manager
      homeModules = import ./modules/home-manager;

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = throwIfGitCryptNotInitialized (nixosConfigurations' ./secrets);

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations = throwIfGitCryptNotInitialized (homeConfigurations' ./secrets);
    };
}
