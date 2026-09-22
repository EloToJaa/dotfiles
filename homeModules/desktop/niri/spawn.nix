{
  config,
  lib,
  pkgs,
  settings,
  ...
}: let
  cfg = config.modules.desktop.niri;
  inherit (settings) discord;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.niri.settings._children = map (args: {spawn-at-startup._args = args;}) [
      # System tray apps
      # ["poweralertd"]
      # ["wl-clip-persist" "--clipboard" "both"]
      [(lib.getExe' pkgs.udiskie "udiskie") "--automount" "--notify" "--smart-tray"]
      [discord]
      # ["opencloud"]
      [(lib.getExe pkgs.unstable.valent) "--gapplication-service"]
      [(lib.getExe pkgs.ntfy-sh) "subscribe" "--from-config"]
      [(lib.getExe pkgs.oniri) "--edges-maximizing"]
    ];
  };
}
