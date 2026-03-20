{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.modules.core.wayland;
in {
  options.modules.core.wayland = {
    enable = lib.mkEnableOption "Enable wayland module";
    hyprland.enable = lib.mkEnableOption "Enable hyprland";
    niri.enable = lib.mkEnableOption "Enable niri";
  };
  config = lib.mkIf cfg.enable {
    programs.hyprland = lib.mkIf cfg.hyprland.enable {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };
    programs.niri.package = pkgs.niri-unstable;
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      xdgOpenUsePortal = true;
      config = {
        common.default = ["gtk"];
        hyprland.default = lib.mkIf cfg.hyprland.enable [
          "gtk"
          "hyprland"
        ];
      };
      # extraPortals = with pkgs.unstable; [
      #   xdg-desktop-portal-gtk
      # ];
    };

    boot.initrd.kernelModules = ["amdgpu"];
  };
}
