{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.desktop.hyprland;
in {
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      hyprprop
    ];

    systemd.user.targets.hyprland-session.Unit.Wants = ["xdg-desktop-autostart.target"];
    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;
      # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      # portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      # enableNvidiaPatches = false;
      systemd.enable = true;
    };
    services.hyprpolkitagent = {
      enable = true;
      package = pkgs.unstable.hyprpolkitagent;
    };
  };
}
