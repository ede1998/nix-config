{ ... }:
{
  imports = [ ../nas.nix ];

  disko.devices = {
    disk = {
      internal-ssd = {
        type = "disk";
        device = "/dev/disk/by-id/ata-SAMSUNG_MZNLN512HMJP-000H1_S2Y1NX0HB56120";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              # EFI system partition
              label = "boot";
              size = "1024M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "umask=0077"
                  "defaults"
                ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                settings = {
                  allowDiscards = true;
                  bypassWorkqueues = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-L"
                    "internal-ssd"
                    "-f"
                  ]; # Override existing partition
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/swap" = {
                      mountpoint = "/swap";
                      swap.swapfile.size = "8G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
    nodev = {
      "/tmp" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=8G"
          "noatime"
          "mode=1777"
          "defaults"
        ];
      };
    };
  };
}
