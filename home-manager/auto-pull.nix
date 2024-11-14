{
  pkgs,
  config,
  secrets,
  ...
}:
let
  github_token = builtins.readFile "${secrets}/autoPullNixCfg.cred";
  git = "${pkgs.git}/bin/git";
in
{
  # Based on https://github.com/Misterio77/nix-config/blob/5b8159e3f2aeadc3c6696f93a7818308b378a7df/home/gabriel/features/cli/nix-index.nix
  systemd.user.timers.autoPullNixCfg = {
    Unit.Description = "Automatic github:ede1998/nix-config fetching";
    Timer = {
      OnCalendar = "04:10";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  systemd.user.services.autoPullNixCfg = {
    Unit = {
      Description = "Fetch ede1998/nix-config and synchronize the local nixos configuration with upstream";
      After = [ "network-online.target" ];
      Requires = [ "ssh-agent.service" ];
    };

    Service = {
      Type = "oneshot";
      # Starts with `-` so failure is ignored when remote is already added
      ExecStartPre = "-${git} remote add origin-http https://${github_token}@github.com/ede1998/nix-config.git";
      ExecStart = "${git} pull origin-http master";
      # Can we detect this somehow?
      # i.e. where is the nixos configuration directory located?
      WorkingDirectory = "${config.home.homeDirectory}/nix-config";
    };
  };
}
