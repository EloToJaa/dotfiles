{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.desktop;
in {
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ## CLI utility
      pamixer # pulseaudio command line mixer
      playerctl # controller for media players
      poweralertd
      xdg-utils

      ## GUI Apps
      unstable.chromium
      unstable.gimp
      unstable.libreoffice
      unstable.mpv # video player
      unstable.obs-studio
      unstable.pavucontrol # pulseaudio volume controle (GUI)
      unstable.qalculate-gtk # calculator
      unstable.qview # minimal image viewer
      unstable.winetricks
      unstable.wineWowPackages.wayland
      unstable.zenity
      unstable.remmina
      unstable.rnote
      unstable.qbittorrent
      unstable.vaults
      unstable.thunderbird
      unstable.prismlauncher
    ];
  };
}
