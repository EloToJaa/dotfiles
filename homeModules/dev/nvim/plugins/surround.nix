{
  lib,
  config,
  ...
}: let
  cfg = config.modules.home.nvim.plugins.surround;
in {
  options.modules.home.nvim.plugins.surround = {
    enable = lib.mkEnableOption "Enable surround";
  };
  config = lib.mkIf cfg.enable {
    programs.nixvim.plugins = {
      vim-surround.enable = true;
    };
  };
}
