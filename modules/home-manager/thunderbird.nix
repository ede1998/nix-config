{ config, lib, ... }:
with lib;
let
  cfg-calendar = config.accounts.calendar.accounts;
  cfg-contact = config.accounts.contact.accounts;
  cfg-mail-local = config.accounts.email.thunderbird.local-folder;
in
{
  options.accounts = {
    calendar.accounts = mkOption {
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
              options.thunderbird = {
                enable = mkOption {
                  type = types.bool;
                  default = true;
                  description = ''
                    Whether this calendar should be generated. This option allows specific calendars to be disabled.
                  '';
                };

                position = mkOption {
                  type = types.nullOr types.ints.unsigned;
                  default = null;
                  description = ''
                    Position where the calendar should be displayed.
                  '';
                };

                display-name = mkOption {
                  type = types.str;
                  description = "What name to use when displaying the calendar in the UI";
                };

                cache = mkOption {
                  type = types.bool;
                  default = true;
                  description = "Whether to cache the calendar events locally in order to have it available while offline";
                };

                show-in-composite = mkOption {
                  type = types.bool;
                  default = true;
                  description = "Whether to show the calendar in the 3 pane starting view of Thunderbird";
                };

                read-only = mkOption {
                  type = types.bool;
                  default = false;
                  description = "Whether the calendar should be read-only inside Thunderbird or events can be added and modified";
                };

                color = mkOption {
                  type = types.strMatching "#[A-Fa-f0-9]{6}";
                  description = "Color to display the calendar events with";
                };
              };

              config = {
                thunderbird.display-name = mkDefault name;
              };
            }
          )
        );
    };

    contact.accounts = mkOption {
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
              options.thunderbird = {
                enable = mkOption {
                  type = types.bool;
                  default = true;
                  description = ''
                    Whether this contact list should be generated. This option allows specific contact lists to be disabled.
                  '';
                };

                display-name = mkOption {
                  type = types.str;
                  description = "What name to use when displaying the contact list in the UI";
                };
              };

              config = {
                thunderbird.display-name = mkDefault name;
              };
            }
          )
        );
    };

    email.thunderbird.local-folder = {
      enable = mkEnableOption "Thunderbird local folder configuration";
      path = mkOption {
        type = types.path;
        description = "Directory where the mails should be stored locally";
      };
    };

  };

  config = mkIf config.programs.thunderbird.enable {
    warnings =
      let
        cfgToWarnings = msg-lambda: cfg: flatten (mapAttrsToList msg-lambda cfg);
        invalidPasswordCheck =
          type: n: v:
          optional (
            v.thunderbird.enable && v.remote.passwordCommand != null
          ) "Ignoring remote.passwordCommand for Thunderbird configuration of ${type} account ${n}.";
      in
      (cfgToWarnings (invalidPasswordCheck "calendar") cfg-calendar)
      ++ (cfgToWarnings (invalidPasswordCheck "contact") cfg-contact);
    assertions =
      let
        invalidRemoteTypeCheck = n: v: {
          assertion = v.thunderbird.enable && v.remote.type == "carddav";
          message = "Only carddav is supported for Thunderbird contact accounts. Invalid configuration for ${n}.";
        };
      in
      mapAttrsToList invalidRemoteTypeCheck cfg-contact;
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
        genCalendar =
          name: cfg:
          let
            th = cfg.thunderbird;
            rem = cfg.remote;
          in
          optionalAttrs th.enable {
            "calendar.registry.${name}.cache.enabled" = th.cache;
            "calendar.registry.${name}.calendar-main-default" = cfg.primary;
            "calendar.registry.${name}.calendar-main-in-composite" = th.show-in-composite;
            "calendar.registry.${name}.color" = th.color;
            "calendar.registry.${name}.name" = th.display-name;
            "calendar.registry.${name}.readOnly" = th.read-only;
            "calendar.registry.${name}.type" = rem.type;
            "calendar.registry.${name}.uri" = rem.url;
            "calendar.registry.${name}.username" = rem.userName;
          };
        genContactList =
          name: cfg:
          let
            th = cfg.thunderbird;
            rem = cfg.remote;
            to-dir-type-id =
              type:
              {
                ldap = 0;
                mapi = 3;
                js = 101;
                carddav = 102;
                async = 103;
              }
              ."${type}";
          in
          optionalAttrs th.enable {
            "ldap_2.servers.${name}.carddav.url" = rem.url;
            "ldap_2.servers.${name}.carddav.username" = rem.userName;
            "ldap_2.servers.${name}.description" = th.display-name;
            "ldap_2.servers.${name}.dirType" = to-dir-type-id rem.type;
            "ldap_2.servers.${name}.filename" = "${name}.sqlite";
          };
        calendarPositionsToList =
          cfg:
          mapAttrsToList (
            name: value:
            let
              posOrMinus1 =
                x: if x.thunderbird == null || x.thunderbird.position == null then -1 else x.thunderbird.position;
              max-position = fold max (-1) (map posOrMinus1 (attrValues cfg));
              posOrLast = pos: if pos == -1 then max-position + 1 else pos;

              position = posOrMinus1 value;
            in
            {
              inherit name;
              position = posOrLast position;
            }
          ) (filterAttrs (n: v: v.thunderbird != null && v.thunderbird.enable) cfg);
        cmp = lhs: rhs: lhs.position < rhs.position;
        mkSortOrder = calendars: concatStringsSep " " (map (x: x.name) calendars);
      in
      mkMerge (
        (mapAttrsToList genCalendar cfg-calendar)
        ++ (mapAttrsToList genContactList cfg-contact)
        ++ [
          { "calendar.list.sortOrder" = mkSortOrder (sort cmp (calendarPositionsToList cfg-calendar)); }
          (mkIf cfg-mail-local.enable (genMailLocalFolder cfg-mail-local))
        ]
      );
  };
}
