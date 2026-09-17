{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.desktop.hyprland;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.extraLuaFiles.monitors = ./monitors.lua;
    home.packages = with pkgs.unstable; [nwg-displays];
  };
}
