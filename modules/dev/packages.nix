{pkgs, ...}: {
  home.packages = with pkgs.unstable; [
    ## CLI utility
    deploy-rs
    xh
  ];
}
