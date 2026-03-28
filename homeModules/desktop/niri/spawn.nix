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
          "PATH"
          "HOME"
          "USER"
          "XDG_DATA_DIRS"
          "XDG_SESSION_TYPE"
          "XDG_CURRENT_DESKTOP"
          "XDG_SESSION_DESKTOP"
          "WAYLAND_DISPLAY"
          "GTK_THEME"
          "GDK_BACKEND"
          "MOZ_ENABLE_WAYLAND"
          "QT_QPA_PLATFORM"
        ];
      }
      {
        command = [
          "dbus-update-activation-environment"
          "--systemd"
          "PATH"
          "HOME"
          "USER"
          "XDG_DATA_DIRS"
          "XDG_SESSION_TYPE"
          "XDG_CURRENT_DESKTOP"
          "XDG_SESSION_DESKTOP"
          "WAYLAND_DISPLAY"
          "GTK_THEME"
          "GDK_BACKEND"
          "MOZ_ENABLE_WAYLAND"
          "QT_QPA_PLATFORM"
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
