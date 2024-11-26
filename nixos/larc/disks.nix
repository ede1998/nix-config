{ ... }:
{
  imports = [ ../nas.nix ];

  fileSystems = { };

  disko.devices = {
    disk = { };
    nodev = {
      "/tmp" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=32G"
          "noatime"
          "mode=1777"
          "defaults"
        ];
      };
    };
  };
}
