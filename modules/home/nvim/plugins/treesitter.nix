{
  lib,
  config,
  ...
}: let
  cfg = config.modules.home.nvim.plugins.treesitter;
in {
  options.modules.home.nvim.plugins.treesitter = {
    enable = lib.mkEnableOption "Enable treesitter";
  };
  config = lib.mkIf cfg.enable {
    programs.nixvim.plugins.treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
        incremental_selection.enable = true;

        auto_install = true;
      };
    };
  };
}
