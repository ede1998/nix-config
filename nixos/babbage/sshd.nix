{ ... }:
{
  users.users.erik.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPk/i+RMmAfLbm1YNLys6xCbqhZoL2zvYJmeQedaN6RX github@erik-hennig.me" # Fairphone
  ];
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
}
