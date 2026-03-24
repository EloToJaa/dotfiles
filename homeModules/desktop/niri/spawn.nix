{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.desktop.niri;
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

      # Lock screen - hyprlock works on any Wayland compositor
      {command = ["hyprlock"];}

      # System tray apps
      {command = ["nm-applet"];}
      {command = ["poweralertd"];}
      {command = ["wl-clip-persist" "--clipboard" "both"];}
      {command = ["waybar"];}
      {command = ["swaync"];}
      {command = ["udiskie" "--automount" "--notify" "--smart-tray"];}

      # Cursor theme
      {command = ["hyprctl" "setcursor" "Bibata-Modern-Ice" "22"];}

      # Wallpaper
      {command = ["init-wallpaper"];}
    ];
  };
}
