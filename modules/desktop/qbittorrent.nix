{pkgs, ...}: {
  home.packages = with pkgs.unstable; [
    qbittorrent
    vuetorrent
  ];
}
