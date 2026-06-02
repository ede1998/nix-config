{
  pkgs,
  lib,
  secrets,
  ...
}:
let
  credentials = lib.importJSON "${secrets}/win11-rdp.json";

  startScript = pkgs.writeShellApplication {
    name = "start-win11-rdp.sh";
    runtimeInputs = [
      pkgs.netcat-openbsd
      pkgs.curl
      pkgs.jq
    ];
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      exec >/tmp/win11-rdp-launcher.log 2>&1

      echo 'Starting Windows 11 VM (${credentials.vmId}) on Proxmox host ${credentials.pveUrl}...'

      curl -f -s -X POST -H 'Authorization: PVEAPIToken=${credentials.pveToken}' \
        '${credentials.pveUrl}/api2/json/nodes/${credentials.pveNode}/qemu/${credentials.vmId}/status/start' >/dev/null

      sleep 1

      START_RESULT=$(curl -f -s -X GET -H 'Authorization: PVEAPIToken=${credentials.pveToken}' '${credentials.pveUrl}/api2/json/nodes/${credentials.pveNode}/tasks/'"$UPID"'/status' | jq --raw-output '.data.exitstatus')

      grep -q '^\(OK\|VM 106 already running\)$' <<< "$START_RESULT" || {
        echo "Failed to start VM: $START_RESULT Please check Proxmox for details."
        exit 1
      }

      echo 'Waiting for Windows to boot and RDP to become available (timeout 600s)...'

      MAX_WAIT=600
      WAITED=0
      while ! nc -z -w 1 '${credentials.vmIp}' 3389 2>/dev/null; do
        sleep 2
        WAITED=$((WAITED + 2))
        echo -n '.'
        if [ "$WAITED" -ge "$MAX_WAIT" ]; then
          echo
          echo 'Timed out waiting for RDP on ${credentials.vmIp}:3389'
          exit 1
        fi
      done

      echo
      echo 'RDP is up! Launching KRDC...'

      krdc 'rdp://${credentials.vmIp}' &
      disown
    '';
  };
in
{
  home.packages = with pkgs; [ kdePackages.krdc ];

  home.file.".local/share/icons/hicolor/scalable/apps/icon-win11.svg".source = ./icon-win11.svg;
  home.file.".local/share/applications/Windows11-Proxmox.desktop".text = lib.mkForce ''
    [Desktop Entry]
    Name=Windows 11 (Proxmox)
    Comment=Starts Proxmox VM and opens RDP
    Exec=${startScript}/bin/start-win11-rdp.sh
    Icon=icon-win11
    Terminal=false
    Type=Application
    Categories=Network;RemoteAccess;
  '';
}
