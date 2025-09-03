{pkgs, ...}: {
  home.packages = with pkgs.unstable; [
    ## CLI utility
    docfd # TUI multiline fuzzy document finder
    tdf # cli pdf viewer
    xxd
    deploy-rs
    xh
  ];
}
