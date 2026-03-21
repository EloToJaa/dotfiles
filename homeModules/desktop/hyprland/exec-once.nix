{
  config,
  lib,
  ...
}: let
  cfg = config.modules.desktop.hyprland;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings.exec-once = [
      # "hash dbus-update-activation-environment 2>/dev/null &"
      "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE"
      "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE"

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
