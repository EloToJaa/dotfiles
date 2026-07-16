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
        poweralertd
        xdg-utils
      ])
      ++ (with pkgs.unstable; [
        ## Essentials
        chromium
        # google-chrome
        mpv # video player
        pavucontrol # pulseaudio volume controle (GUI)
        qalculate-gtk # calculator
        qview # minimal image viewer
        udiskie

        ## Utilities
        # libreoffice
        gimp
        obs-studio
        qbittorrent
        rustdesk-flutter
        mqtt-explorer
        # opencloud-desktop
        # zoom-us

        ## GNOME Apps
        delfin # jellyfin client
        nocturne # navidrome client
        # newsflash # rss reader
        # zenity # gnome dialog
        # vaults # store sensitive files
        # remmina # remote connection client (vnc, rdp, ssh)

        ## Wayland Utilities
        # wf-recorder # record screen
        # woomer # zoomer for wayland
        libnotify
        ntfy-sh
        tesseract # ocr

        ## Gaming
        # prismlauncher # minecraft launcher
      ]);
  };
}
