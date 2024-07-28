{
  config,
  lib,
  pkgs,
  initial-files,
  ...
}:
with lib;
let
  cfg = config.initial-config.nextcloud-client;
  config-dir = "${config.xdg.configHome}/Nextcloud";
in
{
  # Cannot import here and in home.nix. Error:
  # The option `initial-files.file' in `home.nix' is already declared in initial-files.nix
  # As it is already imported in home.nix, it is passed down to here as function arg.
  # imports = [ ../initial-files.nix ];

  options.initial-config.nextcloud-client = {
    enable = mkEnableOption "Nextcloud Client";
    start-in-background = mkOption {
      type = types.bool;
      description = "Whether to start the Nextcloud client in the background.";
      default = false;
    };
    config-file = mkOption {
      type = types.path;
      description = "nextcloud.cfg file to copy for initial configuration.";
    };
    sync-exclude = mkOption {
      type = types.lines;
      description = "Lists glob patterns to ignore when syncing.";
      default = ''
        *~
        ~$*
        .~lock.*
        ~*.tmp
        ]*.~*
        ]Icon\r*
        ].DS_Store
        ].ds_store
        *.textClipping
        ._*
        ]Thumbs.db
        ]photothumb.db
        System Volume Information
        .*.sw?
        .*.*sw?
        ].TemporaryItems
        ].Trashes
        ].DocumentRevisions-V100
        ].Trash-*
        .fseventd
        .apdisk
        .Spotlight-V100
        .directory
        *.part
        *.filepart
        *.crdownload
        *.kate-swp
        *.gnucash.tmp-*
        .synkron.*
        .sync.ffs_db
        .symform
        .symform-store
        .fuse_hidden*
        *.unison
        .nfs*
        My Saved Places.
        \#*#
        *.sb-*
        .git
      '';
    };
  };

  config = mkIf cfg.enable {
    services.nextcloud-client = {
     enable = true;
     startInBackground = cfg.start-in-background;
    };
    initial-files.file."${config-dir}/nextcloud.cfg".source = cfg.config-file;
    home.file."${config-dir}/sync-exclude.lst".text = cfg.sync-exclude;
  };
}
