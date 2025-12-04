{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  credentials = lib.importJSON "${secrets}/mailbox-dav.json";
  mailboxOrgCalendar = id: {
    type = "caldav";
    url = "https://dav.mailbox.org/caldav/${id}/";
    userName = credentials.userName;
    # passwordCommand = [ "${pkgs.coreutils}/bin/echo" credentials.password ];
  };
  mailboxOrgContactList = id: {
    type = "carddav";
    url = "https://dav.mailbox.org/carddav/${toString id}/";
    userName = credentials.userName;
    # passwordCommand = [ "\${pkgs.coreutils}/bin/echo" credentials.password ];
  };
  color = {
    pink = "#FD3297";
    blue = "#1365CA";
    violet = "#4A27D0";
  };
in
{
  accounts.email = {
    accounts.mailbox-org = {
      primary = true;
      address = "erik-hennig@mailbox.org";
      userName = "erik-hennig@mailbox.org";
      realName = "Erik Hennig";

      imap = {
        host = "imap.mailbox.org";
        tls.useStartTls = true;
      };

      smtp = {
        host = "smtp.mailbox.org";
        tls.useStartTls = true;
      };

      # requires thunderbird.programs.profiles.<profile>.withExternalGnupg to work properly
      gpg.key = "4A9A41ADAEDE8D68AB34B94905B608222A57A2FB";

      thunderbird = {
        enable = true;
        settings =
          id:
          let
            sort-order = {
              descending = 2;
            };
            sort-type = {
              by-date = 18;
            };
          in
          {
            "mailnews.default_sort_order" = sort-order.descending;
            "mailnews.default_sort_type" = sort-type.by-date;
            "mail.chat.enabled" = false;
            # Reply from this identity when delivery headers match:
            "mail.identity.id_${id}.catchAllHint" = "*@erik-hennig.me";
            "calendar.week.start" = 1;
          };
      };
    };

    thunderbird.local-folder = {
      enable = true;
      path = "${config.home.homeDirectory}/Documents/mails/backups.sbd";
    };
  };

  accounts.calendar.accounts = {
    "Kalender" = {
      primary = true;

      thunderbird = {
        enable = true;
        color = color.pink;
      };

      # TODO This information is never used by KDE
      remote = mailboxOrgCalendar "Y2FsOi8vMC8zMQ";
    };

    "Geburtstage" = {
      thunderbird = {
        enable = true;
        color = color.blue;
        readOnly = true;
      };

      remote = mailboxOrgCalendar "Y2FsOi8vMS8w";
    };

    "Müllabfuhr" = {
      thunderbird = {
        enable = true;
        color = color.violet;
      };

      remote = mailboxOrgCalendar "Y2FsOi8vMC80Mg";
    };
  };

  accounts.contact.accounts.Kontakte = {
    remote = mailboxOrgContactList 32;
    thunderbird.enable = true;
  };

  programs.thunderbird = {
    enable = true;
    package = pkgs.thunderbird.override {
      extraPolicies.ExtensionSettings = {
        # TODO also add configuration for this plugin to Thunderbird
        # Currently located at home-manager/autoarchive-rules.json
        "autoarchive@erik-hennig.me" = {
          installation_mode = "force_installed";
          install_url = "https://github.com/ede1998/autoarchive/releases/download/1.0/autoarchive-1.0-tb.xpi";
        };
      };
    };
    profiles.default = {
      isDefault = true;
      withExternalGnupg = true;
      calendarAccountsOrder = [
        "Kalender"
        "Geburtstage"
        "Müllabfuhr"
      ];
    };
  };
}
