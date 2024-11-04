{ pkgs, ... }:
{
  programs.starship = {
    enable = true;
    settings = {
      continuation_prompt = "▶▶";
      time.disabled = false;
      status = {
        disabled = false;
        format = "[$symbol $maybe_int]($style) ";
        map_symbol = true;
      };
      custom.ssh_no_keys = {
        description = "SSH missing keys";
        when = with pkgs; "${openssh}/bin/ssh-add -l | ${gnugrep}/bin/grep -q 'no identities'";
        command = "echo 🚫";
        format = "$symbol[$output]($style) ";
        shell = with pkgs; [
          "${bash}/bin/bash"
          "--noprofile"
          "--norc"
        ];
        symbol = "🔑";
        style = "bold fg:red";
      };
    };
  };
}
