{pkgs, ...}: {
  home.packages = with pkgs; [
    ## CLI utility
    binsider
    bitwise # cli tool for bit / hex manipulation
    docfd # TUI multiline fuzzy document finder
    entr # perform action when file change
    fd # find replacement
    file # Show file information
    gtrash # rm replacement, put deleted files in system trash
    hexdump
    killall
    man-pages # extra man pages
    nurl # generate fetch for nix config
    ncdu # disk space
    openssl
    onefetch # fetch utility for git repo
    programmer-calculator
    ripgrep # grep replacement
    tdf # cli pdf viewer
    tldr
    todo # cli todo list
    usbutils
    unzip
    valgrind # c memory analyzer
    wget
    xxd

    ## SQL
    pgcli
    litecli
  ];
}
