{
  config,
  lib,
  ...
}: let
  cfg = config.modules.desktop.hyprland;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings.layerrule = [
      "match:namespace ^(vicinae)$, blur on"
      "match:namespace ^(vicinae)$, ignore_alpha 0"
      "match:namespace ^(vicinae)$, no_anim on"
    ];
  };
}
