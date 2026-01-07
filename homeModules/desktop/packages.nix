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
        jellyfin-desktop
        # libreoffice
        mpv # video player
        obs-studio
        pavucontrol # pulseaudio volume controle (GUI)
        qalculate-gtk # calculator
        qview # minimal image viewer
        winetricks
        wineWowPackages.wayland
        zenity
        remmina
        rnote
        qbittorrent
        udiskie
        vaults
        thunderbird
        rustdesk-flutter
        prismlauncher
        zoom-us
      ]);
  };
}
