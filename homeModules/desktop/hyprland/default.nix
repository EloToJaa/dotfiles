{
  config,
  lib,
  pkgs,
  settings,
  ...
}: let
  cfg = config.modules.desktop.hyprland;
  inherit (settings) discord keyboardLayout;
  substitute = names: values: file:
    builtins.replaceStrings names values (builtins.readFile file);
in {
  options.modules.desktop.hyprland.enable = lib.mkEnableOption "Enable hyprland";

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.unstable.hyprprop];
    home.sessionVariables = {
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
    };
    systemd.user.targets.hyprland-session.Unit.Wants = ["xdg-desktop-autostart.target"];
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      package = null;
      portalPackage = null;
      systemd.enable = true;
      extraLuaFiles = {
        animations = ./animations.lua;
        bindings =
          substitute
          ["@MAIN_MOD@" "@DMS@" "@DISCORD@"]
          [config.modules.desktop.mainMod "dms ipc call" discord]
          ./bindings.lua;
        layers = ./layers.lua;
        settings = substitute ["@KEYBOARD_LAYOUT@"] [keyboardLayout] ./settings.lua;
        startup = substitute ["@DISCORD@"] [discord] ./startup.lua;
        windowrules = substitute ["@DISCORD@"] [discord] ./windowrules.lua;
      };
    };
    services.hyprpolkitagent = {
      enable = true;
      package = pkgs.unstable.hyprpolkitagent;
    };
  };
}
