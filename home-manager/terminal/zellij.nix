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
        unbind "Ctrl g" "Ctrl b" "Ctrl t" "Ctrl h"
        normal {
          bind "Alt f" { ToggleFocusFullscreen; }
          bind "Alt w" { ToggleFloatingPanes; }
        }
        locked {
          unbind "Ctrl g" "Ctrl b" "Ctrl t" "Ctrl h"
          bind "Ctrl k" { SwitchToMode "Normal"; }
        }
        shared_except "locked" {
          unbind "Ctrl g" "Ctrl b" "Ctrl t" "Alt [" "Alt ]" "Ctrl h"
          bind "Ctrl k" { SwitchToMode "Locked"; }
        }
        tmux clear-defaults=true {}
        tab {
          unbind "Ctrl g" "Ctrl b" "Ctrl t" "Ctrl h"
          bind "Ctrl e" { SwitchToMode "Normal"; }
        }
        pane {
          bind "[" { PreviousSwapLayout; }
          bind "]" { NextSwapLayout; }
        }
        move {
          bind "Ctrl j" { SwitchToMode "Normal"; }
        }
        shared_except "tab" "locked" {
          unbind "Ctrl g" "Ctrl b" "Ctrl t" "Ctrl h"
          bind "Ctrl e" { SwitchToMode "Tab"; }
        }
        shared_except "tmux" "locked" {
          unbind "Ctrl g" "Ctrl b" "Ctrl t" "Ctrl h"
        }
        shared_except "move" "locked" {
          bind "Ctrl j" { SwitchToMode "Move"; }
          // TODO PR for status-bar to allow configuration of hotkey display?
          bind "F1" {
              LaunchOrFocusPlugin "forgot" {
                  floating true
              }
          }
        }
      }
      load_plugins {
        // TODO: package properly and install as nixpkgs?
        https://github.com/karimould/zellij-forgot/releases/download/0.4.0/zellij_forgot.wasm
      }
      plugins {
        forgot location="https://github.com/karimould/zellij-forgot/releases/download/0.4.0/zellij_forgot.wasm"
      }
    '';
  };
}
