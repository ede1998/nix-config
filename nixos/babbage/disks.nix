{ config, ... }:
{
  imports = [ ../nas.nix ];

  fileSystems = {
    # Cannot use "${config.users.users.erik.home}/nvme" due to infinite recursion
    "/home/erik/nvme" = {
      # My first NVMe drive, partition 2, the first has windows installed
      device = "/dev/disk/by-uuid/7467cf57-c823-4e93-b078-521fe8879865";
      fsType = "ext4";
    };
    "/home/erik/daten" = {
      # HDD, partition 1, just some extra storage
      device = "/dev/disk/by-uuid/b9867d2a-2c7c-4cb3-8e6a-1b0f3d9fc2da";
      fsType = "ext4";
    };
    "/mnt/shared-hdd" = {
      # HDD, partition 2, NTFS because shared with windows
      device = "/dev/disk/by-uuid/41CAFE1F47FEDFFF";
      fsType = "ntfs-3g";
      options = [
        "defaults"
        "uid=${toString config.users.users.erik.uid}"
        "gid=${toString config.users.groups.users.gid}"
        "dmask=022"
        "fmask=133"
        "windows_names"
      ];
    };
  };

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
