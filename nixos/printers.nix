{ pkgs, ... }:
{
  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.xerox-workcentre-6027 ];
  };
  # Enable auto-discovery of printers
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  hardware.printers = {
    ensurePrinters = [
      {
        name = "Xerox_WorkCentre_6027";
        description = "Xerox WorkCentre 6027 (configured by Nix)";
        location = "Büro";
        deviceUri = "dnssd://Xerox%20WorkCentre%206027%20(50%3A41%3ADF)._pdl-datastream._tcp.local/";
        model = "Xerox/Xerox_WorkCentre_6027.ppd.gz";
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];
    ensureDefaultPrinter = "Xerox_WorkCentre_6027";
  };
}
