{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.home;
in {
  config = lib.mkIf cfg.enable {
    fonts.fontconfig.enable = true;
    home.packages = with pkgs.unstable.nerd-fonts; [
      # Nerd Fonts
      caskaydia-cove
      noto
      jetbrains-mono
      symbols-only
    ];
  };
}
