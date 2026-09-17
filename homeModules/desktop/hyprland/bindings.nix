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
    wayland.windowManager.hyprland.extraLuaFiles.bindings =
      builtins.replaceStrings
      ["@MAIN_MOD@" "@DMS@" "@DISCORD@"]
      [config.modules.desktop.mainMod "dms ipc call" discord]
      (builtins.readFile ./bindings.lua);
  };
}
