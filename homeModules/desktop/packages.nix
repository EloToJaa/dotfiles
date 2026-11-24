{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.desktop;
in {
  config = lib.mkIf cfg.enable {
    home.packages =
      (with pkgs; [
        ## CLI utility
        pamixer # pulseaudio command line mixer
        playerctl # controller for media players
        pavucontrol # pulseaudio volume controle (GUI)
        qview # minimal image viewer
        poweralertd
        xdg-utils

        ## GNOME Apps
        delfin # jellyfin client (Fisch fork, pkgs/delfin)
      ])
      ++ (with pkgs.unstable; [
        ## Essentials
        # google-chrome
        mpv # video player
        qalculate-gtk # calculator
        udiskie

        ## Utilities
        # libreoffice
        obs-studio
        rqbit # qbittorrent
        rustdesk-flutter
        # mqtt-explorer
        # opencloud-desktop
        # zoom-us
        # upscayl
        teams-for-linux

        ## GNOME Apps
        nocturne # navidrome client
        # newsflash # rss reader
        # zenity # gnome dialog
        # vaults # store sensitive files

        ## Wayland Utilities
        # wf-recorder # record screen
        # woomer # zoomer for wayland
        tesseract # ocr
        zbar # QR code decoding

        ## Gaming
      ]);
  };
}
