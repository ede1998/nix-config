{ config, lib, ... }:
with lib;
let
  cfg-mail-local = config.accounts.email.thunderbird.local-folder;
in
{
  options.accounts = {
    email.thunderbird.local-folder = {
      enable = mkEnableOption "Thunderbird local folder configuration";
      path = mkOption {
        type = types.path;
        description = "Directory where the mails should be stored locally";
      };
    };
  };

  config = mkIf config.programs.thunderbird.enable {
    programs.thunderbird.settings =
      let
        genMailLocalFolder = cfg: {
          # account1/server1 is already added by standard home-manager thunderbird module for local folder
          "mail.account.account1.server" = "server1";
          "mail.accountmanager.localfoldersserver" = "server1";
          "mail.server.server1.directory" = cfg.path;
          "mail.server.server1.hostname" = "Local Folders";
          "mail.server.server1.name" = "Local Folders";
          # Disable adaptive junk mail controls for this account
          "mail.server.server1.spamLevel" = 0;
          "mail.server.server1.type" = "none";
          "mail.server.server1.userName" = "nobody";
        };
      in
      (mkIf cfg-mail-local.enable (genMailLocalFolder cfg-mail-local));
  };
}
