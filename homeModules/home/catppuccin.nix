{
  config,
  lib,
  settings,
  ...
}: let
  inherit (settings) catppuccin;
  cfg = config.modules.home.catppuccin;
in {
  options.modules.home.catppuccin = {
    enable = lib.mkEnableOption "Enable catppuccin";
  };
  config = lib.mkIf cfg.enable {
    catppuccin = {
      enable = true;
      inherit (catppuccin) flavor accent;

      # mako.enable = false;
    };
  };
}
