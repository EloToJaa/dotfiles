{pkgs, ...}: {
  home.packages = with pkgs.unstable; [swaynotificationcenter];
  xdg.configFile."swaync/style.css".source = ./style.css;
  xdg.configFile."swaync/config.json".source = ./config.json;
}
