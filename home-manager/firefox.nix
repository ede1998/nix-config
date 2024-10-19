{ lib, pkgs, ... }:
let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
  browser-action = {
    plasma-integration = "plasma-browser-integration_kde_org-browser-action";
    bitwarden = "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action";
    one-tab = "extension_one-tab_com-browser-action";
    i-dont-care-about-cookies = "jid1-kkzogwgsw3ao4q_jetpack-browser-action";
    facebook-container = "_contain-facebook-browser-action";
    cookies-txt = "_12cf650b-1822-40aa-bff0-996df6948878_-browser-action";
    wayback-machine = "wayback_machine_mozilla_org-browser-action";
    tos-dr = "jid0-3guet1r69sqnsrca5p8kx9ezc3u_jetpack-browser-action";
    ublock-origin = "ublock0_raymondhill_net-browser-action";
    sponsor-block = "sponsorblocker_ajay_app-browser-action";
  };
  inherit (lib.attrsets) attrValues;
in
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox.override {
      cfg.nativeMessagingHosts.packages = [ pkgs.kdePackages.plasma-browser-integration ];
    };

    # ---- POLICIES ----
    # Check about:policies#documentation for options.
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Cryptomining = true;
        Fingerprinting = true;
      } // lock-true;
      DisablePocket = true;
      DisableSetDesktopBackground = true;
      # Don't show first run or post update page
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DontCheckDefaultBrowser = true;
      DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
      DisplayMenuBar = "always"; # alternatives: "default-off", "never" or "default-on"
      SearchBar = "separate"; # alternative: "unified"

      AutofillCreditCardEnabled = false;
      AutofillAddressEnabled = false;
      OfferToSaveLogins = false;

      FirefoxHome = {
        Search = true;
        SponsoredTopSites = false;

        # TODO check what these 3 are
        TopSites = true;
        Highlights = true;
        Snippets = true;

        Pocket = false;
        SponsoredPocket = false;
        Locked = true;
      };

      # ---- EXTENSIONS ----
      # Check about:support for extension/add-on ID strings.
      # Valid strings for installation_mode are "allowed", "blocked",
      # "force_installed" and "normal_installed".
      # ExtensionSettings = { };

      # ---- PREFERENCES ----
      # Check about:config for options.
      # For documentation, you might find stuff here but it is out of date:
      # https://kb.mozillazine.org/About:config_entries
      # Sometimes, settings are mentioned in policies documentation.
      # Otherwise, use https://searchfox.org/ to search code.
      Preferences = {
        # TODO these should be covered by other settings/policies/etc
        # TODO "browser.search.defaultenginename" = "DuckDuckGo";
        # TODO "browser.search.order.1" = "DuckDuckGo";
        # TODO "extensions.pocket.enabled" = lock-false;
        # TODO "browser.startup.homepage_override.mstone" = "ignore"; # don't show different homepage after upgrade
        # TODO "startup.homepage_override_url" = ""; # unset alternate homepage after upgrade
        # TODO "trailhead.firstrun.didSeeAboutWelcome" = lock-true;
        # TODO Disable crappy home activity stream page
        # TODO "browser.newtabpage.activity-stream.feeds.topsites" = false;
        # TODO "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        # TODO "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts" = false;
        # TODO "signon.rememberSignons" = lock-false; # Disable "save password" prompt
        "general.autoScroll" = lock-true; # Scroll with mouse wheel click
        "browser.contentblocking.category" = {
          Value = "strict";
          Status = "locked";
        };

        # Disable irritating first-run stuff
        "browser.disableResetPrompt" = lock-true;
        "browser.feeds.showFirstRunUI" = lock-false;
        "browser.messaging-system.whatsNewPanel.enabled" = lock-false;
        "browser.rights.3.shown" = lock-true; # know your rights popup
        "browser.shell.checkDefaultBrowser" = lock-false;
        "browser.shell.defaultBrowserCheckCount" = 1;
        "browser.uitour.enabled" = lock-false;

        # Harden
        "dom.security.https_only_mode" = lock-true;
        # Layout
        "browser.uiCustomization.state" = builtins.toJSON {
          currentVersion = 20;
          # newElementCount = 5;
          dirtyAreaCache = [
            "nav-bar"
            # "PersonalToolbar"
            "toolbar-menubar"
            "TabsToolbar"
            "widget-overflow-fixed-list"
          ];
          placements = {
            # PersonalToolbar = [ "personal-bookmarks" ];
            TabsToolbar = [
              "firefox-view-button"
              "tabbrowser-tabs"
              "new-tab-button"
              "alltabs-button"
            ];
            nav-bar = with browser-action; [
              "back-button"
              "forward-button"
              "stop-reload-button"
              "personal-bookmarks"
              "urlbar-container"
              "search-container"
              "downloads-button"
              bitwarden
              one-tab
              tos-dr
              "unified-extensions-button"
            ];
            toolbar-menubar = [ "menubar-items" ];
            unified-extensions-area = with browser-action; [
              ublock-origin
              sponsor-block
              wayback-machine
              i-dont-care-about-cookies
              cookies-txt
              facebook-container
              plasma-integration
            ];
            # widget-overflow-fixed-list = [ ];
          };
          seen = [
            "save-to-pocket-button"
            "developer-button"
            "downloads-button"
          ] ++ attrValues browser-action;
        };
      };
    };
    profiles.default = {
      isDefault = true;
      search = {
        force = true;
        default = "SearXNG";
        privateDefault = "SearXNG";
        order = [
          "SearXNG"
          "dict.cc"
          "DuckDuckGo"
          "Nix Packages"
          "Home Manager Options"
          "Google"
        ];
        engines = {
          "SearXNG" = {
            urls = [
              {
                template = "https://gruble.de/search?q={searchTerms}";
                # or via params = [{ name = "q"; value = "{searchTerms}"; }];
              }
            ];
            iconUpdateURL = "https://searx.space/favicon.ico";
          };
          "dict.cc" = {
            urls = [ { template = "https://dict.cc?s={searchTerms}"; } ];
            iconUpdateURL = "https://www.dict.cc/favicon.ico";
            definedAliases = [ "@dict" ];
          };
          "Nix Packages" = {
            urls = [ { template = "https://search.nixos.org/packages?type=packages&query={searchTerms}"; } ];
            icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
          "Home Manager Options" = {
            urls = [ { template = "https://home-manager-options.extranix.com/?query={searchTerms}"; } ];
            icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@hm" ];
          };
          "Bing".metaData.hidden = true;
          "Wikipedia (en)".metaData.hidden = true;
          "Actions".metaData.hidden = false;
        };
      };

      settings = {
        # Cannot be set in policies for stability reasons
        "privacy.trackingprotection.enabled" = true;
      };
    };
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };
}
