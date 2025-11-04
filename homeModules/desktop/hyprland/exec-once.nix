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
      "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"

      "hyprlock"

      "nm-applet &"
      "poweralertd &"
      "wl-clip-persist --clipboard both &"
      "wl-paste --watch cliphist store &"
      "waybar &"
      "swaync &"
      "udiskie --automount --notify --smart-tray &"
      "hyprctl setcursor Bibata-Modern-Ice 22 &"
      "init-wallpaper &"

      # "kdeconnect-indicator &"
    ];
  };
}
