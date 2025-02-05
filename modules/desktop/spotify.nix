{pkgs, ...}: {
  home.packages = with pkgs; [
    spotube
  ];
}
