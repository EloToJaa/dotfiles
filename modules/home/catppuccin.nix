{
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.home.catppuccin;
in {
  options.modules.home.catppuccin = {
    enable = lib.mkEnableOption "Enable catppuccin";
  };
  imports = [inputs.catppuccin.homeModules.catppuccin];
  config = lib.mkIf cfg.enable {
    catppuccin = {
      enable = true;
      inherit (config.modules.settings.catppuccin) flavor accent;

      # mako.enable = false;
    };
  };
}
