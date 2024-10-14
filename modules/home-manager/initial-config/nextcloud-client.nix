{ config, lib, ... }:
with lib;
let
  cfg = config.initial-config.nextcloud-client;
  config-dir = "${config.xdg.configHome}/Nextcloud";
  folder-sync' = filter (item: item.enable) (attrValues cfg.folder-sync);
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

    instance-url = mkOption {
      type = (types.strMatching "^http.*");
      example = "https://nextcloud.example.com";
      description = "URL of the Nextcloud instance where the files are stored.";
    };

    user = mkOption {
      type = types.str;
      example = "francis";
      description = "Username to do the syncronisation for";
    };

    folder-sync = mkOption {
      default = { };
      example = literalExpression ''
        "/Documents" = {
          localPath = "$'{config.home.homeDirectory}/nextcloud/Docs";
          ignoreHiddenFiles = false;
          paused = true;
        };
        "/Pictures" = {
          localPath = "$'{config.home.homeDirectory}/nextcloud/Pics";
          ignoreHiddenFiles = false;
        };
      '';
      description = "File groups that should be synchronised with Nextcloud.";
      type =
        with types;
        attrsOf (
          submodule (
            {
              name,
              config,
              options,
              ...
            }:
            {
              options = {
                enable = mkOption {
                  type = types.bool;
                  default = true;
                  description = ''
                    Whether this entry should be generated.
                    This option allows specific entries to be disabled.
                  '';
                };

                paused = mkOption {
                  type = types.bool;
                  default = false;
                  description = "Whether the synchronisation should initially start out paused.";
                };

                localPath = mkOption {
                  type = types.path;
                  description = ''
                    The location in the local file system where the remote
                    files should be downloaded to.
                  '';
                };

                remotePath = mkOption {
                  type = types.str;
                  description = "The remote location where the files are orginating from or are uploaded to.";
                };

                virtualFilesMode = mkOption {
                  default = false;
                  type = types.bool;
                  description = ''
                    If true, files are not downloaded until accessed.
                    Might only work properly under Windows.
                  '';
                };

                ignoreHiddenFiles = mkOption {
                  default = true;
                  type = types.bool;
                  description = ''Whether to sync hidden files.'';
                };
              };

              config = {
                remotePath = mkDefault name;
              };
            }
          )
        );
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
    initial-files = {
      file."${config-dir}/nextcloud.cfg".text = generators.toINI { } (
        let
          makeSyncEntry =
            index: cfg:
            let
              prefix = "0\\Folders\\${toString index}\\";
            in
            {
              "${prefix}ignoreHiddenFiles" = cfg.ignoreHiddenFiles;
              "${prefix}virtualFilesMode" = if cfg.virtualFilesMode then "on" else "off";
              "${prefix}localPath" = cfg.localPath;
              "${prefix}targetPath" = cfg.remotePath;
              "${prefix}paused" = cfg.paused;
              "${prefix}version" = 2;
            };
          sync-entries = mergeAttrsList (imap1 makeSyncEntry folder-sync');
        in
        {
          General.clientVersion = "3.13.0";
          Accounts = {
            version = 2;
            "0\\authType" = "webflow";
            "0\\dav_user" = cfg.user;
            "0\\displayName" = cfg.user;
            "0\\url" = cfg.instance-url;
            "0\\webflow_user" = cfg.user;
          } // sync-entries;
        }
      );
      directory =
        let
          dirs' = map (e: e.localPath) folder-sync';
        in
        genAttrs dirs' (key: { });
    };
    home.file."${config-dir}/sync-exclude.lst".text = cfg.sync-exclude;
  };
}
