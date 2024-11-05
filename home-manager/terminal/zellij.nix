{ lib, config, ... }:
{
  programs.zellij = {
    enable = true;
    enableBashIntegration = true;
  };
  # kdl support in nix is pretty limited
  xdg.configFile."zellij/config.kdl" = lib.mkIf (config.programs.zellij.enable) {
    text = ''
      pane_viewport_serialization true;
      scrollback_lines_to_serialize 10000;
      scroll_buffer_size -1;
      pane_frames false;
      keybinds {
        unbind "Ctrl g" "Ctrl b" "Ctrl t"
        locked {
          unbind "Ctrl g" "Ctrl b" "Ctrl t"
          bind "Ctrl k" { SwitchToMode "Normal"; }
        }
        shared_except "locked" {
          unbind "Ctrl g" "Ctrl b" "Ctrl t"
          bind "Ctrl k" { SwitchToMode "Locked"; }
        }
        tab {
          unbind "Ctrl g" "Ctrl b" "Ctrl t"
          bind "Ctrl e" { SwitchToMode "Normal"; }
        }
        shared_except "tab" "locked" {
          unbind "Ctrl g" "Ctrl b" "Ctrl t"
          bind "Ctrl e" { SwitchToMode "Tab"; }
        }
        shared_except "tmux" "locked" {
          unbind "Ctrl g" "Ctrl b" "Ctrl t"
        }
      }
    '';
  };

  /*
    plugins {
        tab-bar location="zellij:tab-bar"
        status-bar location="zellij:status-bar"
        strider location="zellij:strider"
        compact-bar location="zellij:compact-bar"
        session-manager location="zellij:session-manager"
        welcome-screen location="zellij:session-manager" {
            welcome_screen true
        }
        filepicker location="zellij:strider" {
            cwd "/"
        }
    }

    // For more examples, see: https://github.com/zellij-org/zellij/tree/main/example/themes
    // The name of the default layout to load on startup
    // Default: "default"
    //
    // default_layout "compact"
  */
}
