{
  pkgs,
  config,
  ...
}:
let
  git = "${pkgs.git}/bin/git";
  bash = "${pkgs.bash}/bin/bash";
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
      ExecStartPre = "${git} remote add origin-http https://github.com/ede1998/nix-config.git";
      # Make pulling work whether branch is checked out or not
      ExecStart = "${bash} -c '${git} fetch origin-http master:master || ${git} pull origin-http master --rebase'";
      ExecStopPost = "${git} remote remove origin-http";
      # Can we detect this somehow?
      # i.e. where is the nixos configuration directory located?
      WorkingDirectory = "${config.home.homeDirectory}/nix-config";
    };
  };
}
