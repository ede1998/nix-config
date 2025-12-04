{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  # Bootloader.
  boot.loader = {
    systemd-boot = {
      enable = true;
      memtest86.enable = true;
    };

    efi.canTouchEfiVariables = true;
  };
  security.tpm2.enable = true;
  boot.initrd.systemd.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelPatches =
    let
      kernelVersion = "6.17"; # TODO bore is not released yet for 6.18 so we cannot get it like this: lib.versions.majorMinor config.boot.kernelPackages.kernel.version;
      patchesDir = "${inputs.bore-scheduler-src}/patches/stable/linux-${kernelVersion}-bore";
    in
    lib.mapAttrsToList (name: _: {
      name = "bore-${name}";
      patch = "${patchesDir}/${name}";
    }) (builtins.readDir patchesDir);
}
