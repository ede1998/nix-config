{ ... }:
{
  programs.konsole = {
    enable = true;
    extraConfig = {
      MainWindow.MenuBar = "Disabled";
      "Shortcut Schemes"."Current Scheme" = "EmptyKeybindings";
    };
  };
  xdg.dataFile."konsole/shortcuts/EmptyKeybindings".text = ''
    <gui name="konsole" version="1">
      <ActionProperties>
        <Action name="edit_paste" shortcut="Ctrl+Shift+V"/>
      </ActionProperties>
    </gui>
  '';
}
