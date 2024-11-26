{ pkgs, ... }:
{
  programs.partition-manager.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.plasma6.excludePackages = with pkgs.kdePackages; [ elisa ];

  environment.systemPackages = with pkgs; [ kdiskmark ];

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
}
