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
  variables = {
    inherit discord;
    keyboard_layout = keyboardLayout;
    main_mod = config.modules.desktop.mainMod;
  };
  imports = ["dms.outputs"];
in {
  options.modules.desktop.hyprland.enable = lib.mkEnableOption "Enable hyprland";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      hyprprop
    ];
    systemd.user.targets.hyprland-session.Unit.Wants = ["xdg-desktop-autostart.target"];
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      extraConfig = lib.concatMapStringsSep "\n" (module: "require(${toLua module})") imports;
      package = null;
      portalPackage = null;
      xdph.settings.screencopy.custom_picker_binary = "${pkgs.unstable.hyprland-preview-share-picker}/bin/hyprland-preview-share-picker";
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
          content = "return ${toLua variables}";
        };
      };
    };
    services.hyprpolkitagent = {
      enable = true;
      package = pkgs.unstable.hyprpolkitagent;
    };
  };
}
