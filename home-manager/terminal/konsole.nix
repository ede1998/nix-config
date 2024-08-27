{ ... }:
{
  programs.konsole = {
    enable = true;
    extraConfig = {
      MainWindow.MenuBar = false;
    };
  };
}
