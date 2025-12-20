{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.core.wayland;
in {
  options.modules.core.wayland = {
    enable = lib.mkEnableOption "Enable wayland module";
  };
  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      package = pkgs.unstable.hyprland;
      portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
    };
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      xdgOpenUsePortal = true;
      config = {
        common.default = ["gtk"];
        hyprland.default = [
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
