{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  inherit (inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}) hyprland xdg-desktop-portal-hyprland;
  inherit (config.settings) username;
  niri = pkgs.niri-unstable;
  cfg = config.modules.core.wayland;
in {
  options.modules.core.wayland = {
    enable = lib.mkEnableOption "Enable wayland module";
    hyprland.enable = lib.mkEnableOption "Enable hyprland";
    niri.enable = lib.mkEnableOption "Enable niri";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.optionals cfg.niri.enable [
      niri
    ];

    programs = {
      hyprland = lib.mkIf cfg.hyprland.enable {
        enable = true;
        package = hyprland;
        portalPackage = xdg-desktop-portal-hyprland;
        withUWSM = true;
      };
      # niri = lib.mkIf cfg.niri.enable {
      #   enable = true;
      #   package = pkgs.niri-unstable;
      # };
      uwsm = {
        enable = true;
        package = pkgs.unstable.uwsm;
        waylandCompositors = {
          # hyprland = lib.mkIf cfg.hyprland.enable {
          #   prettyName = "Hyprland";
          #   comment = "Hyprland compositor managed by UWSM";
          #   binPath = "${hyprland}/bin/Hyprland";
          # };
          niri = lib.mkIf cfg.niri.enable {
            prettyName = "Niri";
            comment = "Niri compositor managed by UWSM";
            binPath = "${niri}/bin/niri";
          };
        };
      };
    };
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

    services.greetd = let
      session = {
        command = "${lib.getExe config.programs.uwsm.package} start ${hyprland}/share/wayland-sessions/hyprland.desktop";
        user = username;
      };
    in {
      enable = true;

      # do not restart on session exit (useful on autologin)
      restart = false;

      settings = {
        terminal.vt = 1;
        default_session = session;
        initial_session = session;
      };
    };

    boot.initrd.kernelModules = ["amdgpu"];
  };
}
