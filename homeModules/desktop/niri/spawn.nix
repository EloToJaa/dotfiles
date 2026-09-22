{
  config,
  lib,
  pkgs,
  inputs,
  settings,
  ...
}: let
  cfg = config.modules.desktop.niri;
  inherit (settings) discord;
  niri-session-manager = inputs.niri-session-manager.packages.${pkgs.stdenv.hostPlatform.system}.default;
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
      [(lib.getExe niri-session-manager)]
    ];
  };
}
