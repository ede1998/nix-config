{ pkgs, lib, ... }:
{
  home.packages = [ pkgs.blesh ];
  programs.bash.initExtra = lib.mkMerge [
    (lib.mkOrder 99 ''source "${pkgs.blesh}/share/blesh/ble.sh" --noattach'')
    (lib.mkOrder 1501 "[[ ! $\{BLE_VERSION-} ]] || ble-attach")
  ];
  xdg.configFile."blesh/init.sh".text = ''
    # -*- mode: sh; mode: sh-bash -*-

    # Disable elapsed-time marker like "[ble: elapsed 1.203s (CPU 0.4%)]"
    bleopt exec_elapsed_mark=

    # Disable exit marker like "[ble: exit]"
    bleopt exec_exit_mark=

    # Disable error exit marker for commands like "[ble: exit 1]"
    bleopt exec_errexit_mark=

    ## The following setting controls the history sharing. If it has non-empty
    ## value, the history sharing is enabled. With the history sharing, the command
    ## history is shared with the other Bash ble.sh sessions with the history
    ## sharing turned on.
    bleopt history_share=1

    ## "exec_restore_pipestatus" controls whether ble.sh restores PIPESTATUS of the
    ## previous user command.  When this option is set to a non-empty value,
    ## PIPESTATUS is restored.  This feature is turned off by default because it
    ## adds extra execution costs.  Note that the values of PIPESTATUS of the
    ## previous command are always available with the array BLE_PIPESTATUS
    ## regardless of this setting.
    bleopt exec_restore_pipestatus=1

    ## This option controls the target range in the command history for
    ## "erasedups", which is performed when it is specified in "HISTCONTROL".  When
    ## this option has an empty value, the target range is the entire history as in
    ## the plain Bash.  When this option evaluates to a positive integer "count",
    ## the target range is the last "n" entries in the command history.  When this
    ## option evaluates to a non-positive integer "offset", "offset" specifies the
    ## beginning of the target range relative to the history count at the session
    ## start.  The end of the target range is always the end of the command
    ## history.
    # Entire history
    bleopt history_erasedups_limit=
  '';
}
