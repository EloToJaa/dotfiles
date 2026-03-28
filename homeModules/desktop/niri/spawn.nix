{
  config,
  lib,
  settings,
  ...
}: let
  cfg = config.modules.desktop.niri;
  inherit (settings) discord;

  uwsmApp = command: ["uwsm" "app" "--"] ++ command;
in {
  config = lib.mkIf cfg.enable {
    programs.niri.settings.spawn-at-startup = [
      # Export all session variables to dbus and systemd
      {
        command = [
          "systemctl"
          "--user"
          "import-environment"
        ];
      }
      {
        command = [
          "dbus-update-activation-environment"
          "--all"
        ];
      }

      # System tray apps
      {command = uwsmApp ["dms" "run"];}
      {command = uwsmApp ["poweralertd"];}
      {command = uwsmApp ["wl-clip-persist" "--clipboard" "both"];}
      {command = uwsmApp ["udiskie" "--automount" "--notify" "--smart-tray"];}
      {command = uwsmApp [discord];}
      {command = uwsmApp ["nextcloud" "--background"];}
    ];
  };
}
