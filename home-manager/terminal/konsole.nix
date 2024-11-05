{ ... }:
{
  programs.konsole = {
    enable = true;
    extraConfig = {
      MainWindow.MenuBar = false;
      "Shortcut Schemes"."Current Scheme" = "EmptyKeybindings";
    };
  };
  xdg.dataFile."konsole/shortcuts/EmptyKeybindings".text = ''
    <gui>
      <ActionProperties/>
    </gui>'';
}
