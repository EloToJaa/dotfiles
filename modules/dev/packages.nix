{pkgs, ...}: {
  home.packages = with pkgs.unstable; [
    ## CLI utility
    binsider
    bitwise # cli tool for bit / hex manipulation
    docfd # TUI multiline fuzzy document finder
    entr # perform action when file change
    gping
    hexdump
    nurl # generate fetch for nix config
    ncdu # disk space
    onefetch # fetch utility for git repo
    pastel
    programmer-calculator
    tdf # cli pdf viewer
    todo # cli todo list
    valgrind # c memory analyzer
    xxd
    hyperfine
    deploy-rs
    xh

    ## SQL
    pgcli
    litecli
  ];
}
