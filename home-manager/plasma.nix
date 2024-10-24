{ ... }:
{
  programs.plasma = {
    enable = true;
    overrideConfig = true;
    # Run rc2nix tool to see current config formatted as nix: `nix run github:nix-community/plasma-manager`

    powerdevil.AC = {
      autoSuspend.action = "nothing";
      turnOffDisplay = {
        idleTimeout = 900;
      };
    };

    # Some high-level settings:
    workspace = {
      clickItemTo = "select";
      lookAndFeel = "org.kde.breezedark.desktop";
      #cursor.theme = "Bibata-Modern-Ice";
      #iconTheme = "Papirus-Dark";
      #wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Patak/contents/images/1080x1920.png";
    };

    #hotkeys.commands."launch-konsole" = {
    #  name = "Launch Konsole";
    #  key = "Meta+Alt+K";
    #  command = "konsole";
    #};

    panels = [
      # Windows-like panel at the top
      {
        location = "top";
        screen = 2;
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          {
            iconTasks.launchers = [
              "applications:org.kde.dolphin.desktop"
              "applications:firefox.desktop"
              "applications:thunderbird.desktop"
            ];
          }
          "org.kde.plasma.marginsseparator"
          { systemTray.items.hidden = [ "org.kde.plasma.battery" ]; }
          {
            digitalClock = {
              calendar = {
                firstDayOfWeek = "monday";
                plugins = [ "holidaysevents" ];
                showWeekNumbers = true;
              };
              date.format = "isoDate";
              time = {
                format = "24h";
                showSeconds = "always";
              };
            };
          }
        ];
      }
      # Global menu at the top
      # {
      #   location = "top";
      #   height = 26;
      #   widgets = [
      #     "org.kde.plasma.appmenu"
      #   ];
      # }
    ];

    # Some mid-level settings:
    shortcuts = {
      #ksmserver = {
      #  "Lock Session" = [ "Screensaver" "Meta+Ctrl+Alt+L" ];
      #};

      kwin = {
        "Switch Window Down" = "Meta+J";
        "Switch Window Left" = "Meta+H";
        "Switch Window Right" = "Meta+L";
        "Switch Window Up" = "Meta+K";
      };
    };

    kwin = {
      titlebarButtons.left = [
        "on-all-desktops"
        "keep-above-windows"
        "application-menu"
      ];
      virtualDesktops = {
        number = 4;
        rows = 4;
      };
    };

    # Some low-level settings:
    configFile =
      let
        hot-corner.disabled = 9;
        numlock.active-on-startup = 0;
      in
      {
        baloofilerc."Basic Settings".Indexing-Enabled = false;
        # Disable KDE global menu daemon
        kded5rc.Module-appmenu.autoload = false;
        # https://github.com/nix-community/plasma-manager/issues/117#issuecomment-2041384419
        kcminputrc.Keyboard.NumLock.value = numlock.active-on-startup;
        kwinrc = {
          # Forces kde to not change this value (even through the settings app).
          Desktops.Number.immutable = true;
          # Disable effects when cursor is on screen edge
          # Source: https://www.reddit.com/r/kde/comments/r5xir0/comment/hoehzhq
          Effect-overview.BorderActivate = hot-corner.disabled;
        };
      };
  };
}
