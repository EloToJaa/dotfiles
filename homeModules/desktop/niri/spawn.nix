{
  config,
  lib,
  settings,
  ...
}: let
  cfg = config.modules.desktop.niri;
  inherit (settings) discord;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.niri.settings.spawn-at-startup = [
      # System tray apps
      # ["poweralertd"]
      # ["wl-clip-persist" "--clipboard" "both"]
      ["udiskie" "--automount" "--notify" "--smart-tray"]
      [discord]
      # ["opencloud"]
      ["valent" "--gapplication-service"]
    ];
  };
}
