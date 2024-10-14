{
  disko.devices = {
    disk = {
      wd-blue-sn580 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WD_Blue_SN580_2TB_24332A400426";
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
                    "wd-blue-sn580-btrfs"
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
                      mountOptions = [ "compress=zstd" ];
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
                      swap.swapfile.size = "32G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
