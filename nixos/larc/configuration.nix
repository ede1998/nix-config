# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{ inputs, ... }:
{
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd
    inputs.disko.nixosModules.disko

    # You can also split up your configuration and import pieces of it here:
    ../boot.nix
    ../locale.nix
    ../nix.nix
    ../plasma.nix
    ../printers.nix
    ../sound.nix
    ../user.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./disks.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "larc";
  networking.networkmanager = {
    enable = true;
    ensureProfiles.profiles = {
      "38C3" = {
        connection = {
          id = "38C3";
          type = "wifi";
        };
        wifi = {
          mode = "infrastructure";
          ssid = "38C3";
        };
        wifi-security = {
          auth-alg = "open";
          key-mgmt = "wpa-eap";
        };
        "802-1x" = {
          anonymous-identity = "38C3";
          eap = "ttls;";
          identity = "38C3";
          password = "38C3";
          phase2-auth = "pap";
          altsubject-matches = "DNS:radius.c3noc.net";
          ca-cert = "${builtins.fetchurl {
            url = "https://letsencrypt.org/certs/isrgrootx1.pem";
            sha256 = "sha256:1la36n2f31j9s03v847ig6ny9lr875q3g7smnq33dcsmf2i5gd92";
          }}";
        };
        ipv4 = {
          method = "auto";
        };
        ipv6 = {
          addr-gen-mode = "default";
          method = "auto";
        };
      };
    };
  };
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  virtualisation.docker.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
