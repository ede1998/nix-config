{ config, ... }:
let
  cifs-filesystem = {
    fsType = "cifs";
    options = [
      "credentials=/etc/samba/QNAP-NAS.cred"
      "uid=${toString config.users.users.erik.uid}"
      "gid=${toString config.users.groups.users.gid}"
      "workgroup=WORKGROUP"
      "ip=192.168.140.100"
      "vers=2.0"
      "mfsymlinks"
    ];
  };
in
{
  fileSystems = {
    "/mnt/erikdoc" = {
      device = "//QNAP-NAS/home";
      inherit (cifs-filesystem) fsType options;
    };
    "/mnt/multimedia" = {
      device = "//QNAP-NAS/multimedia";
      inherit (cifs-filesystem) fsType options;
    };
    "/mnt/download" = {
      device = "//QNAP-NAS/Download";
      inherit (cifs-filesystem) fsType options;
    };
    "/mnt/container" = {
      device = "//QNAP-NAS/Container";
      inherit (cifs-filesystem) fsType options;
    };
  };
  environment.etc."samba/QNAP-NAS.cred" = {
    source = ../secrets/QNAP-NAS.cred;
    mode = "0600";
  };
}
