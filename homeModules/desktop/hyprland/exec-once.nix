{
  config,
  lib,
  settings,
  ...
}: let
  inherit (settings) discord;
  cfg = config.modules.desktop.hyprland;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings.exec-once = [
      # Home Manager's Hyprland target starts DMS and other user services.
      "systemctl --user import-environment --all"
      "dbus-update-activation-environment --systemd --all"

      # Keep application startup aligned with niri.
      "udiskie --automount --notify --smart-tray"
      discord
      "valent --gapplication-service"
      "ntfy subscribe --from-config"
    ];
  };
}
