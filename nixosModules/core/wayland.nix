{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.modules.core.wayland;
  hyprland = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
in {
  options.modules.core.wayland = {
    enable = lib.mkEnableOption "Enable wayland module";
    hyprland.enable = lib.mkEnableOption "Enable hyprland";
    niri.enable = lib.mkEnableOption "Enable niri";
  };
  config = lib.mkIf cfg.enable {
    programs = {
      hyprland = lib.mkIf cfg.hyprland.enable {
        enable = true;
        package = hyprland;
        portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };
      niri = lib.mkIf cfg.niri.enable {
        enable = true;
        package = pkgs.niri-unstable;
      };
      uwsm = {
        enable = true;
        package = pkgs.unstable.uwsm;
        waylandCompositors = {
          hyprland = {
            prettyName = "Hyprland";
            comment = "Hyprland compositor managed by UWSM";
            binPath = "${hyprland}/bin/Hyprland";
          };
          niri = {
            prettyName = "Niri";
            comment = "Niri compositor managed by UWSM";
            binPath = "${pkgs.niri-unstable}/bin/niri";
          };
        };
      };
    };
    niri-flake.cache.enable = cfg.niri.enable;
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
