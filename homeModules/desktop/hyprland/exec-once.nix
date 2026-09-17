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
    wayland.windowManager.hyprland.extraLuaFiles.startup =
      builtins.replaceStrings
      ["@DISCORD@"]
      [discord]
      (builtins.readFile ./startup.lua);
  };
}
