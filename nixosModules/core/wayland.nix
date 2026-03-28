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
    environment.pathsToLink = ["/share/applications" "/share/xdg-desktop-portal"];

    programs = {
      hyprland = lib.mkIf cfg.hyprland.enable {
        enable = true;
        package = hyprland;
        portalPackage = xdg-desktop-portal-hyprland;
      };
      niri = lib.mkIf cfg.niri.enable {
        enable = true;
        package = niri;
      };
    };
    systemd.user.services.niri-flake-polkit.enable = false;
    services.dbus.implementation = "broker";

    services = {
      xserver.displayManager.lightdm.enable = false;
      greetd = {
        enable = true;

        settings = {
          terminal.vt = 1;
          default_session.user = username;
        };
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
