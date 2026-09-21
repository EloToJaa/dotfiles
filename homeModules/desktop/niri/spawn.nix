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
    wayland.windowManager.niri.settings._children = map (args: {spawn-at-startup._args = args;}) [
      # System tray apps
      # ["poweralertd"]
      # ["wl-clip-persist" "--clipboard" "both"]
      ["udiskie" "--automount" "--notify" "--smart-tray"]
      [discord]
      # ["opencloud"]
      ["valent" "--gapplication-service"]
      ["ntfy" "subscribe" "--from-config"]
      ["oniri" "--edges-maximizing"]
    ];
  };
}
