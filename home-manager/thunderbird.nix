{ lib, ... }:
rec {
  accounts.email.accounts.mailbox-org = {
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

    thunderbird = {
      enable = true;
      settings = id: {
        "mailnews.default_sort_order" = 2; # descending
        "mailnews.default_sort_type" = 18; # by date
      };
    };
  };
  programs.thunderbird = {
    enable = true;
    profiles.default = {
      isDefault = true;
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
