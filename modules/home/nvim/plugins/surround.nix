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
  programs.nixvim.plugins = {
    vim-surround.enable = cfg.enable;
  };
}
