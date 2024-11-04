{ ... }:
{
  programs.fzf = {
    enable = true;
    changeDirWidgetCommand = "";
    fileWidgetOptions = [
      "--preview 'if [ -d {} ]; then tree -C {} | head -n 200; elif file {} | grep image -q; then viu -w 80 {}; else bat --color=always {}; fi'"
      "--bind 'ctrl-/:change-preview-window(down|hidden|right:80%|)'"
      "--color header:italic"
      "--header 'Press CTRL-/ to toggle preview window'"
    ];
    historyWidgetOptions = [
      "--preview 'echo {}'"
      "--color header:italic"
      "--header 'CTRL-Y copy to clipboard; CTRL+R sort; CTRL+/ = toggle preview'"
      "--preview-window down:3:hidden:wrap"
      "--bind 'ctrl-/:toggle-preview'"
      "--bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'"
    ];
  };
}
