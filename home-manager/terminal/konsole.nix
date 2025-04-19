{ pkgs, config, ... }:
{
  programs.konsole = {
    enable = true;
    extraConfig = {
      MainWindow.MenuBar = "Disabled";
      "Shortcut Schemes"."Current Scheme" = "EmptyKeybindings";
    };
    defaultProfile = "standard";
    profiles.standard = {
      command = "${config.programs.zellij.package}/bin/zellij";
      extraConfig."Interaction Options".MiddleClickPasteMode = true;
    };
  };
  xdg.dataFile."konsole/shortcuts/EmptyKeybindings".text = ''
    <gui name="konsole" version="1">
      <ActionProperties>
        <Action name="edit_paste" shortcut="Ctrl+Shift+V; Shift+Ins"/>
      </ActionProperties>
    </gui>
  '';
}
