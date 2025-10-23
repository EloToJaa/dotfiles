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
      swww
      grimblast
      hyprprop
      hyprpicker
      grim
      slurp
      wf-recorder
      glib
      wayland
      woomer # zoomer for wayland
      libnotify
    ];

    systemd.user.targets.hyprland-session.Unit.Wants = ["xdg-desktop-autostart.target"];
    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;
      xwayland = {
        enable = true;
        # hidpi = true;
      };
      # enableNvidiaPatches = false;
      systemd.enable = true;
    };
  };
}
