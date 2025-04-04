{
  config,
  secrets,
  lib,
  ...
}:
let
  credentials = lib.importJSON "${secrets}/nextcloud.json";
  instance-url = "https://cloud.erik-hennig.me";
in
{
  initial-config.nextcloud-client = {
    enable = true;
    start-in-background = true;
    inherit (credentials) user;
    inherit instance-url;
    folder-sync = {
      "/Documents" = {
        localPath = "${config.home.homeDirectory}/Documents";
        ignoreHiddenFiles = false;
      };
      "/Pictures" = {
        localPath = "${config.home.homeDirectory}/Pictures";
        ignoreHiddenFiles = false;
      };
      "/shared" = {
        localPath = "${config.home.homeDirectory}/nextcloud-shared";
        ignoreHiddenFiles = false;
      };
    };
  };
  nextcloud-tag-sync = {
    enable = true;
    frequency = "*:1";
    inherit instance-url;
    inherit (credentials) user token;
    prefixes = [
      {
        remote = "/remote.php/dav/files/${credentials.user}/Documents";
        local = "${config.home.homeDirectory}/Documents";
      }
      {
        remote = "/remote.php/dav/files/${credentials.user}/Pictures";
        local = "${config.home.homeDirectory}/Pictures";
      }
      {
        remote = "/remote.php/dav/files/${credentials.user}/shared";
        local = "${config.home.homeDirectory}/nextcloud-shared";
      }
    ];
  };
}
