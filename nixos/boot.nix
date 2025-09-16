{
  pkgs,
  inputs,
  lib,
  config,
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
      patchesDir = "${inputs.bore-scheduler-src}/patches/stable/linux-${lib.versions.majorMinor config.boot.kernelPackages.kernel.version}-bore";
    in
    lib.mapAttrsToList (name: _: {
      name = "bore-${name}";
      patch = "${patchesDir}/${name}";
    }) (builtins.readDir patchesDir);
}
