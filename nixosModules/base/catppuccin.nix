{
  config,
  lib,
  ...
}: let
  inherit (config.settings) catppuccin;
  cfg = config.modules.base.catppuccin;
in {
  options.modules.base.catppuccin = {
    enable = lib.mkEnableOption "Enable catppuccin";
  };
  config = lib.mkIf cfg.enable {
    catppuccin = {
      enable = true;
      inherit (catppuccin) flavor accent;

      gtk.icon.enable = false;
      cache.enable = true;
    };
  };
}
