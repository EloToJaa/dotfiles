{
  config,
  lib,
  pkgs,
  settings,
  ...
}: let
  cfg = config.modules.desktop.hyprland;
  inherit (settings) discord keyboardLayout;
  toLua = lib.generators.toLua {};
in {
  options.modules.desktop.hyprland.enable = lib.mkEnableOption "Enable hyprland";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [hyprprop];
    systemd.user.targets.hyprland-session.Unit.Wants = ["xdg-desktop-autostart.target"];
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      extraConfig = ''
        require("dms.outputs")
      '';
      package = null;
      portalPackage = null;
      systemd.enable = true;
      extraLuaFiles = {
        animations = ./animations.lua;
        bindings = ./bindings.lua;
        layers = ./layers.lua;
        settings = ./settings.lua;
        startup = ./startup.lua;
        windowrules = ./windowrules.lua;
        variables = {
          autoLoad = false;
          content =
            /*
            lua
            */
            ''
              local M = {}
              M.discord = ${toLua discord}
              M.keyboard_layout = ${toLua keyboardLayout}
              M.main_mod = ${toLua config.modules.desktop.mainMod}
              return M
            '';
        };
      };
    };
    services.hyprpolkitagent = {
      enable = true;
      package = pkgs.unstable.hyprpolkitagent;
    };
  };
}
