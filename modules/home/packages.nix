{pkgs, ...}: {
  home.packages = with pkgs; [
    ## CLI utility
    fd # find replacement
    file # Show file information
    gtrash # rm replacement, put deleted files in system trash
    killall
    man-pages # extra man pages
    openssl
    ripgrep # grep replacement
    tldr
    usbutils
    unzip
    wget

    lazydocker
  ];
}
