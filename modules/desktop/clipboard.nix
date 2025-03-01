{pkgs, ...}: {
  home.packages = with pkgs; [
    wl-clipboard # clipboard utils for wayland (wl-copy, wl-paste)
    wl-clip-persist # persist clipboard between wayland sessions
    cliphist # clipboard history
  ];

  xdg.configFile."cliphist/config".text = ''
    max-items = 100
  '';
}
