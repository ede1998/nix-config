{ config, ... }:
{
  initial-config.gnucash = {
    enable = true;
    show-first-startup = false;
    show-tip-of-the-day = false;
    custom-reports = ./reports.scm;
    import-directory = "${config.home.homeDirectory}/tmp/transactions";
    books.finances = {
      default = true;
      file-path = "${config.home.homeDirectory}/Documents/finanzen/gnucash1/finances.gnucash";
      metadata = ./finances.gnucash.gcm;
    };
  };
}
