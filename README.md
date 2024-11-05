# ede1998's NixOS configuration

## Bootstrapping a new system

- Start a [NixOS live system](https://nixos.org/download#download-nixos).
- Login to Github in browser and get a new personal access token (scope Content)
```bash
git clone https://github.com/ede1998/nix-config.git
cd nix-config
nix-shell
# Decode secrets
wl-paste | base64 -d | git crypt unlock -
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
  `cfg = homeConfigurations."erik@nixos-erik-desktop".config`
  `lib = nixosConfigurations.nixos-erik-desktop.lib`
  `pkgs = nixosConfigurations.nixos-erik-desktop.pkgs`
  `:p <expr>`
- Update your flake lock with `nix flake update` to get the latest packages and modules.


## Features

*Based on [Misterio77/nix-starter-configs](https://github.com/Misterio77/nix-starter-configs/tree/f1ecf7e2275f541af7bec763866a909224b937a4)*

- Basic boilerplate for adding custom packages (under `pkgs`) and overlays (under `overlay`).
  Accessible on your system, home config, as well as `nix build .#package-name`.
- Boilerplate for custom NixOS (`modules/nixos`) and home-manager (`modules/home-manager`) modules
- NixOS and home-manager configurations from minimal, and they should also use your overlays and custom packages right out of the box.


### Use home-manager as a NixOS module

If you prefer to build your home configuration together with your NixOS one,
it's pretty simple.

Simply remove the `homeConfigurations` block from the `flake.nix` file; then
add this to your NixOS configuration (either directly on
`nixos/configuration.nix` or on a separate file and import it):

```nix
{ inputs, outputs, ... }: {
  imports = [
    # Import home-manager's NixOS module
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      # Import your home-manager configuration
      your-username = import ../home-manager/home.nix;
    };
  };
}
```

In this setup, the `home-manager` tool will not be installed (see
[nix-community/home-manager#4342](https://github.com/nix-community/home-manager/pull/4342)).
To rebuild your home configuration, use `nixos-rebuild` instead.

But if you want to install the `home-manager` tool anyways, you can add the
package into your configuration:

```nix
# To install it for a specific user
users.users = {
  your-username = {
    packages = [ inputs.home-manager.packages.${pkgs.system}.default ];
  };
};

# To install it globally
environment.systemPackages =
  [ inputs.home-manager.packages.${pkgs.system}.default ];
```

### Adding more hosts or users

You can organize them by hostname and username on `nixos` and `home-manager`
directories, be sure to also add them to `flake.nix`.

You can take a look at my (beware, here be reproducible dragons)
[configuration repo](https://github.com/misterio77/nix-config) for ideas.

NixOS makes it easy to share common configuration between hosts (you might want
to create a common directory for these), while keeping everything in sync.
home-manager can help you sync your environment (from editor to WM and
everything in between) anywhere you use it. Have fun!

### User password and secrets

You have basically two ways of setting up default passwords:
- By default, you'll be prompted for a root password when installing with
  `nixos-install`. After you reboot, be sure to add a password to your own
  account and lock root using `sudo passwd -l root`.
- Alternatively, you can specify `initialPassword` for your user. This will
  give your account a default password, be sure to change it after rebooting!
  If you do, you should pass `--no-root-passwd` to `nixos-install`, to skip
  setting a password on the root account.

If you don't want to set your password imperatively, you can also use
`passwordFile` for safely and declaratively setting a password from a file
outside the nix store.

There's also [more advanced options for secret
management](https://nixos.wiki/wiki/Comparison_of_secret_managing_schemes),
including some that can include them (encrypted) into your config repo and/or
nix store, be sure to check them out if you're interested.

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

### Try opt-in persistence

You might have noticed that there's impurity in your NixOS system, in the form
of configuration files and other cruft your system generates when running. What
if you change them in a whim to get something working and forget about it?
Boom, your system is not fully reproducible anymore.

You can instead fully delete your `/` and `/home` on every boot! Nix is okay
with a empty root on boot (all you need is `/boot` and `/nix`), and will
happily reapply your configurations.

There's two main approaches to this: mount a `tmpfs` (RAM disk) to `/`, or
(using a filesystem such as btrfs or zfs) mount a blank snapshot and reset it
on boot.

For stuff that can't be managed through nix (such as games downloaded from
steam, or logs), use [impermanence](https://github.com/nix-community/impermanence)
for mounting stuff you to keep to a separate partition/volume (such as
`/nix/persist` or `/persist`). This makes everything vanish by default, and you
can keep track of what you specifically asked to be kept.

Here's some awesome blog posts about it:
- [Erase your darlings](https://grahamc.com/blog/erase-your-darlings)
- [Encrypted BTRFS with Opt-In State on
  NixOS](https://mt-caret.github.io/blog/posts/2020-06-29-optin-state.html)
- [NixOS: tmpfs as root](https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/) and
  [tmpfs as home](https://elis.nu/blog/2020/06/nixos-tmpfs-as-home/)

Note that for `home-manager` to work correctly here, you need to set up its
NixOS module, as described in the [previous section](#use-home-manager-as-a-nixos-module).

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

