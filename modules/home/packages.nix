{ inputs, pkgs, ... }:
{
  home.packages = (with pkgs; [
    ## CLI utility
    binsider
    bitwise                           # cli tool for bit / hex manipulation
    caligula                          # User-friendly, lightweight TUI for disk imaging
    chromium
    dconf-editor
    docfd                             # TUI multiline fuzzy document finder
    eza                               # ls replacement
    entr                              # perform action when file change
    fd                                # find replacement
    ffmpeg
    file                              # Show file information 
    gtrash                            # rm replacement, put deleted files in system trash
    hexdump
    imv                               # image viewer
    jq
    killall
    libnotify
	  man-pages					            	  # extra man pages
    mpv                               # video player
    nurl                              # generate fetch for nix config
    ncdu                              # disk space
    openssl
    onefetch                          # fetch utility for git repo
    pamixer                           # pulseaudio command line mixer
    playerctl                         # controller for media players
    poweralertd
    programmer-calculator
    # qview                             # minimal image viewer
    ripgrep                           # grep replacement
    swappy                            # snapshot editing tool
    tdf                               # cli pdf viewer
    tldr
    todo                              # cli todo list
    usbutils
    unzip
    valgrind                          # c memory analyzer
    wl-clipboard                      # clipboard utils for wayland (wl-copy, wl-paste)
    wget
    yazi                              # terminal file manager
    yt-dlp-light
    xdg-utils
    xxd

    ## CLI 
    tty-clock                         # cli clock

    ## GUI Apps
    audacity
    bleachbit                         # cache cleaner
    gimp
    libreoffice
    nix-prefetch-github
    obs-studio
    pavucontrol                       # pulseaudio volume controle (GUI)
    pitivi                            # video editing
    qalculate-gtk                     # calculator
    vlc
    winetricks
    wineWowPackages.wayland
    zenity
    qbittorrent

    # C / C++
    gcc
    gdb
    gnumake

    # Python
    python3

    nodejs
    npm-check-updates

    inputs.alejandra.defaultPackage.${system}
  ]);
}
