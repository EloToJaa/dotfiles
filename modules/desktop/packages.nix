{pkgs, ...}: {
  home.packages = with pkgs; [
    ## CLI utility
    libnotify
    pamixer # pulseaudio command line mixer
    playerctl # controller for media players
    poweralertd
    swappy # snapshot editing tool
    wl-clipboard # clipboard utils for wayland (wl-copy, wl-paste)
    caligula # User-friendly, lightweight TUI for disk imaging
    tty-clock # cli clock
    yt-dlp-light

    ## GUI Apps
    audacity
    bleachbit # cache cleaner
    chromium
    dconf-editor
    gimp
    imv # image viewer
    libreoffice
    mpv # video player
    nix-prefetch-github
    obs-studio
    pavucontrol # pulseaudio volume controle (GUI)
    pitivi # video editing
    qalculate-gtk # calculator
    # qview                             # minimal image viewer
    winetricks
    wineWowPackages.wayland
    zenity
    remmina

    xdg-utils
  ];
}
