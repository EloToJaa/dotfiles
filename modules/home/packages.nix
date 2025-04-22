{pkgs, ...}: {
  home.packages = with pkgs; [
    ## CLI utility
    gtrash # rm replacement, put deleted files in system trash
    killall
    man-pages # extra man pages
    openssl
    usbutils
    unzip
    wget

    neovim
  ];
}
