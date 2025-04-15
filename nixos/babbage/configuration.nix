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

    ./sshd.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./disks.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "babbage";
  networking.networkmanager.enable = true;
  networking.interfaces.enp7s0.wakeOnLan.enable = true;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
  programs.kdeconnect.enable = true;

  virtualisation.docker.enable = true;

  services.udev.extraRules = ''
    # Block webcam sound
    # Do not want low quality webcam mic: https://rietta.com/blog/block-webcam-audio-ubuntu-linux/
    # the webcam in question: Bus 003 Device 011: ID 1871:0341 Aveo Technology Corp.
    SUBSYSTEM=="usb", DRIVER=="snd-usb-audio", ATTRS{idVendor}=="1871", ATTRS{idProduct}=="0341", ATTR{authorized}="0"
  '';

  services.ollama = {
    enable = true;
    acceleration = "rocm";
    # Required to make ollama actually use the GPU:
    # https://wiki.nixos.org/wiki/Ollama
    rocmOverrideGfx = "10.3.0";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
