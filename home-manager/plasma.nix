{ lib, options, ... }:
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
    kscreenlocker.timeout = 120;

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
                plugins = [
                  "holidaysevents"
                  "pimevents"
                ];
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

    resetFiles = with options.programs.plasma.resetFiles; [ "gwenviewrc" ] ++ default;

    # Some low-level settings:
    configFile =
      let
        hot-corner.disabled = 9;
        numlock.active-on-startup = 0;
      in
      {
        baloofilerc."Basic Settings".Indexing-Enabled = false;
        katerc.General."Close After Last" = true;
        gwenviewrc = {
          # Need to have LastUsedVersion set or menubar config will be removed
          # Also must be MenuBar must be immutable or the value will be reset
          # if LastUsedVersion is unset. However, immutable seem to not really
          # be respected: the key will be removed anyway. Also, its value can
          # be modified within the program (ctrl+m)
          General.LastUsedVersion.persistent = true;
          MainWindow.MenuBar = {
            immutable = true;
            value = true;
          };

          SideBar = {
            "IsVisible ViewMode" = true;
            PreferredMetaInfoKeyList = lib.concatStringsSep "," [
              "General.Name"
              "General.Size"
              "General.LocalPath"
              "General.ImageSize"
              "Exif.Photo.DateTimeDigitized"
              "Exif.Image.Model"
              "Exif.GPSInfo.GPSLatitude"
              "Exif.Image.Make"
              "Exif.Photo.DateTimeOriginal"
              "Exif.GPSInfo.GPSLongitude"
              "Exif.Image.DateTime"
            ];
          };
        };

        dolphinrc = {
          General = {
            RememberOpenedTabs = false;
            ShowFullPath = true;
          };
          # Sadly, the show menu bar configuration is stored in
          # $XDG_DATA_HOME/dolphin/dolphinstaterc in the State.State field
          # which is encoded very weirdly
        };

        # Digital clock
        # Display holidays for Baden-Württemberg in Digital Clock calendar widget.
        plasma_calendar_holiday_regions.General.selectedRegion = "de-bw_de";
        # TODO also automatically configure those calendars
        # at the moment, I added these manually via
        # nix run nixpkgs#kdePackages.akonadiconsole
        # and add davgroupware resource
        plasmashellrc.PIMEventsPlugin.calendars = lib.strings.concatStringsSep "," [
          "15"
          "16"
          "17"
          "18"
        ];

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
