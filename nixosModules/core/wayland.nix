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
          niri = lib.mkIf cfg.niri.enable {
            prettyName = "Niri";
            comment = "Niri compositor managed by UWSM";
            binPath = "${niri}/bin/niri";
          };
        };
      };
    };
    systemd.user.services.niri-flake-polkit.enable = !cfg.niri.enable;
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

    services.xserver.displayManager.lightdm.enable = false;
    services.greetd = {
      enable = true;

      settings = {
        terminal.vt = 1;
        default_session.user = username;
      };
    };

    programs.dank-material-shell.greeter = {
      enable = true;
      compositor.name = "niri"; # Required. Can be also "hyprland" or "sway"

      # Sync your user's DankMaterialShell theme with the greeter. You'll probably want this
      configHome = "/home/${username}";

      # Save the logs to a file
      logs = {
        save = true;
        path = "/tmp/dms-greeter.log";
      };

      # Custom Quickshell Package
      quickshell.package = pkgs.unstable.quickshell;
    };

    boot.initrd.kernelModules = ["amdgpu"];
  };
}
