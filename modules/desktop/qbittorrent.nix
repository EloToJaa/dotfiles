{pkgs, ...}: let
  vuetorrent = pkgs.callPackage ../../pkgs/vuetorrent.nix {};
in {
  home.packages = with pkgs; [
    qbittorrent
    vuetorrent
  ];
}
