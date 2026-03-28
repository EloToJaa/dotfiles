{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.desktop.niri;
in {
  config = lib.mkIf cfg.enable {
    # environment.systemPackages = with pkgs.unstable; [
    #   xwayland-satellite
    # ];

    xdg.portal = {
      config.niri = {
        default = ["gnome" "gtk"];
        "org.freedesktop.impl.portal.Access" = "gtk";
        "org.freedesktop.impl.portal.Notification" = "gtk";
        "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
        "org.freedesktop.impl.portal.ScreenCast" = "wlr";
        "org.freedesktop.portal.ScreenCast" = "wlr";
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
        xdg-desktop-portal-wlr
      ];
    };

    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };
  };
}
