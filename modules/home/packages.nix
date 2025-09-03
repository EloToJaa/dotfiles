{pkgs, ...}: {
  home.packages = with pkgs.unstable; [
    ## CLI utility
    comma
    gtrash # rm replacement, put deleted files in system trash
    killall
    man-pages # extra man pages
    openssl
    usbutils
    wget
  ];
}
