# ede1998's NixOS configuration

## Bootstrapping a new system

- Start a [NixOS live system](https://nixos.org/download#download-nixos).
```bash
git clone https://github.com/ede1998/nix-config.git
cd nix-config
nix-shell
# Decode secrets
wl-paste | base64 -d | git crypt unlock -
pre-commit install
git config blame.ignoreRevsFile .git-blame-ignore-revs
```
- When creating partitions by hand:
  - Create partitions via CLI
  - Mount your partitions to `/mnt` and run: `nixos-generate-config --root /mnt --dir .`.
  - Integrate resulting files into repository
  - Run `nixos-install --flake .#hostname --no-root-password`
- When creating partitions with [disko](https://github.com/nix-community/disko)
  - Create partitions in nix configuration
  - Run `nixos-generate-config --no-filesystems --no-filesystems --dir .`
  - Integrate resulting files into repository
  - Run `sudo nix run 'github:nix-community/disko#disko-install' -- --flake .#hostname --disk disko-disk-name disk-path`
- Reboot
- Login with default password `correcthorsebatterystaple` and run `passwd` to change it, also change password in KWallet
- Clone repository again
- Run `home-manager switch --flake .#username@hostname`
  - If you don't have home-manager installed, try `nix shell nixpkgs#home-manager`.
- If using LUKS, you can configure auto-unlock via TPM2: `sudo systemd-cryptenroll /dev/LUKS-root-partition --tpm2-device=auto`

## Updating the configuration

- Run `sudo nixos-rebuild switch --flake .#hostname` to apply your system configuration.
- Run `home-manager switch --flake .#username@hostname` to apply your home configuration.
- Run `nix repl` and then type `:lf .` to load this flake into an interactive interpreter
  and check out available options. Useful commands:
  - `cfg = homeConfigurations."erik@nixos-erik-desktop".config`
  - `lib = nixosConfigurations.nixos-erik-desktop.lib`
  - `pkgs = nixosConfigurations.nixos-erik-desktop.pkgs`
  - `:p <expr>`
  - `:e <expr>` to open the source location in $EDITOR (if available)
  -  `printf "$(nix --extra-experimental-features dynamic-derivations eval .#homeConfigurations."erik@babbage".config.programs.bash.initExtra)"` prints the evaluated value, experimental feature required for multiple runs with the same inputs
- Update your flake lock with `nix flake update` to get the latest packages and modules.

## Features

*Based on [Misterio77/nix-starter-configs](https://github.com/Misterio77/nix-starter-configs/tree/f1ecf7e2275f541af7bec763866a909224b937a4)*

- Basic boilerplate for adding custom packages (under `pkgs`) and overlays (under `overlay`).
  Accessible on your system, home config, as well as `nix build .#package-name`.
- Boilerplate for custom NixOS (`modules/nixos`) and home-manager (`modules/home-manager`) modules
- NixOS and home-manager configurations from minimal, and they should also use your overlays and custom packages right out of the box.

### Adding more hosts or users

You can organize them by hostname and username on `nixos` and `home-manager`
directories, be sure to also add them to `flake.nix`.

You can take a look at my (beware, here be reproducible dragons)
[configuration repo](https://github.com/misterio77/nix-config) for ideas.

NixOS makes it easy to share common configuration between hosts (you might want
to create a common directory for these), while keeping everything in sync.
home-manager can help you sync your environment (from editor to WM and
everything in between) anywhere you use it. Have fun!

### Dotfile management with home-manager

Besides just adding packages to your environment, home-manager can also manage
your dotfiles. I strongly recommend you do, it's awesome!

For full nix goodness, check out the home-manager options with `man
home-configuration.nix`. Using them, you'll be able to fully configure any
program with nix syntax and its powerful abstractions.

Alternatively, if you're still not ready to rewrite all your configs to nix
syntax, there's home-manager options (such as `xdg.configFile`) for including
files from your config repository into your usual dot directories. Add your
existing dotfiles to this repo and try it out!

When multiple instances of a key will be merged into a final configuration but
order for the generated configuration file is important, `mkOrder` can be used:
https://nixos.wiki/wiki/NixOS:Properties

### Adding custom packages

Something you want to use that's not in nixpkgs yet? You can easily build and
iterate on a derivation (package) from this very repository.

Create a folder with the desired name inside `pkgs`, and add a `default.nix`
file containing a derivation. Be sure to also `callPackage` them on
`pkgs/default.nix`.

You'll be able to refer to that package from anywhere on your
home-manager/nixos configurations, build them with `nix build .#package-name`,
or bring them into your shell with `nix shell .#package-name`.

See [the manual](https://nixos.org/manual/nixpkgs/stable/) for some tips on how
to package stuff.

`nix develop` can be used to get dropped into a shell with all required build
dependencies available. Use `runPhase` plus the phase name to run a particular
phase (`unpackPhase`, `patchPhase`, ...).

### Adding overlays

Found some outdated package on nixpkgs you need the latest version of? Perhaps
you want to apply a patch to fix a behavior you don't like? Nix makes it easy
and manageable with overlays!

Use the `overlays/default.nix` file for this.

If you're creating patches, you can keep them on the `overlays` folder as well.

See [the wiki article](https://nixos.wiki/wiki/Overlays) to see how it all
works.

Individual packages patched in the overlay can be built with
`nix build .#homeConfigurations.erik@babbage.pkgs.${package_name}`.

### Adding your own modules

Got some configurations you want to create an abstraction of? Modules are the
answer. These awesome files can expose _options_ and implement _configurations_
based on how the options are set.

Create a file for them on either `modules/nixos` or `modules/home-manager`. Be
sure to also add them to the listing at `modules/nixos/default.nix` or
`modules/home-manager/default.nix`.

See [the wiki article](https://nixos.wiki/wiki/Module) to learn more about
them.

## Troubleshooting / FAQ

Please [let me know](https://github.com/Misterio77/nix-starter-config/issues)
any questions or issues you face with these templates, so I can add more info
here!

### Nix says my repo files don't exist, even though they do!

Nix flakes only see files that git is currently tracked, so just `git add .`
and you should be good to go. Files on `.gitignore`, of course, are invisible
to nix - this is to guarantee your build won't depend on anything that is not
on your repo.

### Nix installs the wrong version of software/fails to find new software

The nix dependencies (such as `nixpkgs`) used by your configuration will
strictly follow the `flake.lock` file, using the commits written into it when
you (re)generated.

To update your flake inputs, simply use `nix flake update`.
