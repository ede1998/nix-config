{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
let
  kernelVersion = lib.versions.majorMinor config.boot.kernelPackages.kernel.version;
  patchesDir = "${inputs.bore-scheduler-src}/patches/stable/linux-${kernelVersion}-bore";
in
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

  boot.kernelPatches = lib.mapAttrsToList (name: _: {
    name = "bore-${name}";
    patch = "${patchesDir}/${name}";
  }) (builtins.readDir patchesDir);

  warnings =
    if (kernelVersion != "6.19") then
      [
        "Bore Scheduler: Kernel version is ${kernelVersion}, but bore patches are pinned to be compatible with 6.19. Consider unpinning."
      ]
    else
      [ ];
}
