{ ... }:
{
  users.users.erik = {
    description = "Erik Hennig";
    # Be sure to change the password after rebooting!
    initialPassword = "correcthorsebatterystaple";
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "adbusers"
      "dialout"
      "docker"
      "networkmanager"
      "samba"
      "wheel"
      "wireshark"
    ];
  };
}
