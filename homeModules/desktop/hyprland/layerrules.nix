{
  config,
  lib,
  ...
}: let
  cfg = config.modules.desktop.hyprland;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings.layerrule = [
      "blur,vicinae"
      "ignorealpha 0, vicinae"
      "noanim, vicinae"
    ];
  };
}
