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
      "systemctl --user import-environment PATH HOME USER XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP WAYLAND_DISPLAY GTK_THEME GDK_BACKEND MOZ_ENABLE_WAYLAND QT_QPA_PLATFORM"
      "dbus-update-activation-environment --systemd PATH HOME USER XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP WAYLAND_DISPLAY GTK_THEME GDK_BACKEND MOZ_ENABLE_WAYLAND QT_QPA_PLATFORM"

      "hyprlock"

      "uwsm app -- nm-applet"
      "uwsm app -- poweralertd"
      "uwsm app -- wl-clip-persist --clipboard both"
      # "wl-paste --watch cliphist store"
      "uwsm app -- waybar"
      "uwsm app -- swaync"
      "uwsm app -- udiskie --automount --notify --smart-tray"
      "hyprctl setcursor Bibata-Modern-Ice 22"
      "init-wallpaper"

      # "uwsm app -- kdeconnect-indicator"
    ];
  };
}
