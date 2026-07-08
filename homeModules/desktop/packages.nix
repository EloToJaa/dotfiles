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
        ## GUI Apps
        chromium
        gimp
        delfin
        # libreoffice
        mpv # video player
        obs-studio
        pavucontrol # pulseaudio volume controle (GUI)
        qalculate-gtk # calculator
        qview # minimal image viewer
        zenity
        # remmina # remote connection client (vnc, rdp, ssh)
        qbittorrent
        udiskie
        # vaults
        rustdesk-flutter
        # prismlauncher # minecraft launcher
        mqtt-explorer
        # opencloud-desktop
        # zoom-us
        nocturne # navidrome client

        ## Wayland Utilities
        # grimblast
        # hyprpicker
        # grim
        slurp
        wf-recorder
        wayland
        woomer # zoomer for wayland
        libnotify
        tesseract # ocr
      ]);
  };
}
