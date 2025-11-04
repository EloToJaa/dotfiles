{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.desktop.hyprland;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      # settings.monitor = [
      #   "HDMI-A-1, 1920x1080@60, 0x0, 1"
      #   "DP-2, 1920x1080@165, 1920x0, 1"
      #   "DP-1, 1920x1080@60, 3840x0, 1"
      # ];

      settings.monitor = [",preferred,auto,auto"];

      extraConfig = ''
        # hyprlang noerror true
          source = ~/.config/hypr/monitors.conf
          source = ~/.config/hypr/workspaces.conf
        # hyprlang noerror false
      '';
    };

    home.packages = with pkgs.unstable; [nwg-displays];
  };
}
