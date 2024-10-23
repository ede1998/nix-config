{
  config,
  lib,
  pkgs,
  ...
}:
let
  credentials = lib.importJSON ../secrets/mailbox-dav.json;
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
    green = "#247E1E";
    violet = "#4A27D0";
  };
in
rec {
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
        settings = id: {
          "mailnews.default_sort_order" = 2; # descending
          "mailnews.default_sort_type" = 18; # by date
          "mail.chat.enabled" = false;
        };
      };
    };

    thunderbird.local-folder = {
      enable = true;
      path = "${config.home.homeDirectory}/Documents/mails/backups.sbd";
    };
  };

  accounts.calendar.accounts = {
    mailbox-org-main = {
      primary = true;

      thunderbird = {
        color = color.pink;
        display-name = "Kalender";
        position = 0;
      };

      # TODO This information is never used by KDE
      remote = mailboxOrgCalendar "Y2FsOi8vMC8zMQ";
    };

    mailbox-org-birthdays = {
      thunderbird = {
        color = color.blue;
        display-name = "Geburtstage";
        read-only = true;
        position = 1;
      };

      remote = mailboxOrgCalendar "Y2FsOi8vMS8w";
    };

    mailbox-org-lectures = {
      thunderbird = {
        color = color.green;
        display-name = "Vorlesungen";
        position = 2;
      };

      remote = mailboxOrgCalendar "Y2FsOi8vMC80Ng";
    };

    mailbox-org-trash-pickup = {
      thunderbird = {
        color = color.violet;
        display-name = "Müllabfuhr";
        position = 3;
      };

      remote = mailboxOrgCalendar "Y2FsOi8vMC80Mg";
    };
  };

  accounts.contact.accounts.Kontakte.remote = mailboxOrgContactList 32;

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
      # Work-around for repeated creation of new profile
      # https://github.com/nix-community/home-manager/issues/5031
      settings = {
        "mail.accountmanager.accounts" =
          let
            toHashedName = x: "account_" + (builtins.hashString "sha256" x);
            accountUsesThunderbird = account_name: accounts.email.accounts."${account_name}".thunderbird.enable;
            account-names = lib.filter accountUsesThunderbird (lib.attrNames accounts.email.accounts);
          in
          lib.concatStringsSep "," ((map toHashedName account-names) ++ [ "account1" ]);
      };
    };
  };
}
