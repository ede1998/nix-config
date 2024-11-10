{ pkgs, ... }:
{
  programs.starship = {
    enable = true;
    settings = {
      continuation_prompt = "▶▶";
      time.disabled = false;
      status = {
        disabled = false;
        format = "[$symbol $status]($style) ";
        map_symbol = true;
      };
      shlvl = {
        disabled = false;
        threshold = 1;
      };
      nix_shell = {
        heuristic = true;
        unknown_msg = "nix shell";
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
