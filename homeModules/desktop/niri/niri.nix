{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.desktop.niri;
  gnome-portal-niri = pkgs.xdg-desktop-portal-gnome.overrideAttrs (old: {
    postInstall = ''
      ${old.postInstall or ""}
      substituteInPlace $out/share/xdg-desktop-portal/portals/gnome.portal \
        --replace-fail 'UseIn=gnome' 'UseIn=gnome;niri'
    '';
  });
in {
  config = lib.mkIf cfg.enable {
    # environment.systemPackages = with pkgs.unstable; [
    #   xwayland-satellite
    # ];

    # xdg.portal = {
    #   config.niri = {
    #     default = ["gnome" "gtk"];
    #     "org.freedesktop.impl.portal.Access" = "gtk";
    #     "org.freedesktop.impl.portal.Notification" = "gtk";
    #     "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
    #     "org.freedesktop.impl.portal.FileChooser" = "gtk";
    #     "org.freedesktop.impl.portal.ScreenCast" = "gnome";
    #     "org.freedesktop.portal.ScreenCast" = "gnome";
    #   };
    #   extraPortals = with pkgs; [
    #     xdg-desktop-portal-gtk
    #     gnome-portal-niri
    #   ];
    # };

    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };
  };
}
