{pkgs, ...}: {
  home.packages = with pkgs; [
    qbittorrent
    vuetorrent
  ];
}
