{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.core.wayland;
in {
  config = lib.mkIf (config.modules.core.enable && cfg.enable && cfg.hyprland.enable) {
    programs.hyprland = {
      enable = true;
      package = pkgs.unstable.hyprland;
      portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
      withUWSM = false;
      xwayland.enable = true;
    };
  };
}
