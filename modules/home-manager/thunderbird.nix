{ config, lib, ... }:
with lib;
let
  cfg = config.accounts.calendar.accounts;
in
{
  options.accounts.calendar.accounts = mkOption {
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
                description = "What name to use when display the calendar in the UI";
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

  config = mkIf config.programs.thunderbird.enable {
    warnings =
      let
        cfg-to-warnings = msg-lambda: flatten (mapAttrsToList msg-lambda cfg);
      in
      cfg-to-warnings (
        n: v:
        optional (
          v.thunderbird.enable && v.remote.passwordCommand != null
        ) "Ignoring remote.passwordCommand for Thunderbird configuration of calendar account ${n}"
      );
    programs.thunderbird = {
      settings =
        let
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
          (mapAttrsToList genCalendar cfg)
          ++ [ { "calendar.list.sortOrder" = mkSortOrder (sort cmp (calendarPositionsToList cfg)); } ]
        );
    };
  };
}
