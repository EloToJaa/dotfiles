{pkgs, ...}: {
  home.packages = with pkgs.unstable; [
    ## CLI utility
    libnotify
    pamixer # pulseaudio command line mixer
    playerctl # controller for media players
    poweralertd
    swappy # snapshot editing tool
    woomer # zoomer for wayland

    ## GUI Apps
    chromium
    gimp
    # imv # image viewer
    libreoffice
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
    jetbrains.idea-community
    qbittorrent
    vaults

    android-studio

    xdg-utils
  ];
}
