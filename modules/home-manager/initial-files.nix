{ config, lib, pkgs, ... }:
with lib;
let
  files' = filter (f: f.enable) (attrValues config.initial-files.file);
in {
  options.initial-files.file = mkOption {
    default = {};
    example = literalExpression ''
      { example-configuration-file = {
            source = "./etc/dir/file.conf.example";
            mode = "0440";
        };
        "default/useradd".text = "GROUP=100 ...";
      }
    '';
    description = ''
      Set of files to be copied to provide an initial configuration
      for a program. Any already existing files are ignored.
    '';

    type = with types; attrsOf (submodule (
      { name, config, options, ... }:
      { options = {

          enable = mkOption {
            type = types.bool;
            default = true;
            description = ''
              Whether this file should be generated. This
              option allows specific files to be disabled.
            '';
          };

          force = mkOption {
              type = types.bool;
              default = false;
              description = ''
                If true, always generate this file
                and overwrite a potentially existing one.
              '';
          };

          target = mkOption {
            type = types.str;
            description = ''
              Path of the file. Defaults to the attribute name.
            '';
          };

          text = mkOption {
            default = null;
            type = types.nullOr types.lines;
            description = "Text of the file.";
          };

          source = mkOption {
            type = types.path;
            description = ''
              Path of the source file.
              Ensure that this file is in git if using flakes.
            '';
          };

          permissions = mkOption {
            type = types.str;
            default = "0644";
            example = "0700";
            description = "The permission to give the file.";
          };

          user = mkOption {
            default = "";
            type = types.str;
            description = ''
              User name of created file.
              Defaults to the current user.
            '';
          };

          group = mkOption {
            default = "";
            type = types.str;
            description = ''
              Group name of created file.
              Defaults to the current user's group.
            '';
          };

        };

        config = {
          target = mkDefault name;
          source = mkIf (config.text != null) (
            let name' = lib.replaceStrings ["/"] ["-"] name;
            in mkDerivedConfig options.text (pkgs.writeText name')
          );
        };

      }));
  };

  config = {
    home.activation = {
      createInitialFiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
        makeFileEntry() {
          local source="$1";
          local target="$2";
          local force="$3";
          local permissions="$4";
          local user="''${5:-$(id -u)}";
          local group="''${6:-$(id -g)}";
          local target_dir="$(dirname "$target")";

          run mkdir -p "$target_dir"
          # Option errexit is set and would stop script here when cp fails because file exists
          # This is not desirable because the file always exists except for during the first run.
          local exit_code=0
          echo "$force" | run --silence cp --interactive "$source" "$target" || exit_code="$?"

          if [ $exit_code -eq 0 ]; then
            if [ "$force" = "yes" ]; then
              verboseEcho "Forced overwrite: '$source' -> '$target'"
            else
              verboseEcho "'$source' -> '$target'"
            fi
            run chown "$user:$group" "$target" || exit 1
            run chmod "$permissions" "$target" || exit 1
          else
            verboseEcho "File already exists: Skip copying '$source' -> '$target'"
          fi
        }

        verboseEcho "Creating initial files"
        ${concatMapStringsSep "\n" (fileEntry: escapeShellArgs [
        "makeFileEntry"
        # Force local source paths to be added to the store
        "${fileEntry.source}"
        fileEntry.target
        (if fileEntry.force then "yes" else "no")
        fileEntry.permissions
        fileEntry.user
        fileEntry.group
        ]) files'}
      '';
    };
  };
}