{
  lib,
  config,
  ...
}: let
  cfg = config.modules.home.nvim.plugins.lint;
in {
  options.modules.home.nvim.plugins.lint = {
    enable = lib.mkEnableOption "Enable lint";
  };
  config = lib.mkIf cfg.enable {
    programs.nixvim.plugins.lint = {
      enable = true;
    };
  };
}
