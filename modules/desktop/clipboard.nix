{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.desktop.clipboard;
in {
  options.modules.desktop.clipboard = {
    enable = lib.mkEnableOption "Enable clipboard";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      wl-clipboard # clipboard utils for wayland (wl-copy, wl-paste)
      wl-clip-persist # persist clipboard between wayland sessions
      cliphist # clipboard history
    ];
  };
}
