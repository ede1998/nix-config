{ config, ... }:
{

  initial-config.nextcloud-client = {
    enable = true;
    start-in-background = true;
    user = "erik";
    instance-url = "https://cloud.erik-hennig.me";
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
}
