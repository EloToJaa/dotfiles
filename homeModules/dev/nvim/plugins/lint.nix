{
  lib,
  config,
  ...
}: let
  cfg = config.modules.dev.nvim.plugins.lint;
in {
  options.modules.dev.nvim.plugins.lint = {
    enable = lib.mkEnableOption "Enable lint";
  };
  config = lib.mkIf cfg.enable {
    programs.nixvim.plugins.lint = {
      enable = true;
    };
  };
}
