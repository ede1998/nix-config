{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.initial-config.vorta;
in
{
  # Cannot import here and in home.nix. Error:
  # The option `initial-files.file' in `home.nix' is already declared in initial-files.nix
  # As it is already imported in home.nix, it is passed down to here as function arg.
  # imports = [ ../initial-files.nix ];

  options.initial-config.vorta = {
    enable = mkEnableOption "Vorta";
    profiles = mkOption {
      type = types.listOf types.path;
      description = ''
        List of profiles that should be imported for
        initial application installation.
      '';
      default = [ ];
    };
  };

  config.home = mkIf cfg.enable {
    packages = [ pkgs.vorta ];
    activation.import-vorta-profiles =
      let
        marker-file = "${config.xdg.dataHome}/Vorta/.home-manager-profiles-imported";
        import-file = "${config.home.homeDirectory}/.vorta-init.json";
      in
      lib.hm.dag.entryAfter [ "installPackages" ] ''
        import_profile() {
          local profile="$1";
          verboseEcho "Importing profile $profile"

          run cp "$profile" "${import-file}"

          local import_profile_script=$(mktemp)
          trap "rm --force --recursive $import_profile_script" EXIT
          cat > "$import_profile_script" << EOF
        #! /usr/bin/env nix-shell
        #! nix-shell -i expect --packages expect
        spawn ${pkgs.vorta}/bin/vorta
        expect -re "Profile .* imported" { close }
        EOF

          run --quiet nix-shell "$import_profile_script"
        }

        if [ ! -f "${marker-file}" ]; then
          if nix-shell -p procps --run "pgrep 'vorta'" > /dev/null; then
            errorEcho "Please close all existing instances of vorta before activating this home-manager generation";
            exit 1;
          fi

          ${
            concatMapStringsSep "\n" (
              profile:
              escapeShellArgs [
                "import_profile"
                # Force local source paths to be added to the store
                "${profile}"
              ]
            ) cfg.profiles
          }

          run touch "${marker-file}"
        else
          verboseEcho "Skipping import of vorta profiles because marker file ${marker-file} already exists."
        fi
      '';
  };
}
