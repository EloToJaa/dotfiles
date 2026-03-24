{
  config,
  lib,
  ...
}: let
  cfg = config.modules.desktop.hyprland;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings.exec-once = [
      # Export all session variables to dbus and systemd
      "systemctl --user import-environment PATH HOME USER XDG_DATA_DIRS XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP WAYLAND_DISPLAY GTK_THEME GDK_BACKEND MOZ_ENABLE_WAYLAND QT_QPA_PLATFORM"
      "dbus-update-activation-environment --systemd PATH HOME USER XDG_DATA_DIRS XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP WAYLAND_DISPLAY GTK_THEME GDK_BACKEND MOZ_ENABLE_WAYLAND QT_QPA_PLATFORM"

      "hyprlock"

      "nm-applet"
      "poweralertd"
      "wl-clip-persist --clipboard both"
      # "wl-paste --watch cliphist store"
      "waybar"
      "swaync"
      "udiskie --automount --notify --smart-tray"
      "hyprctl setcursor Bibata-Modern-Ice 22"
      "init-wallpaper"

      # "kdeconnect-indicator"
    ];
  };
}
