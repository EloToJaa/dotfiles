{
  lib,
  config,
  ...
}: let
  cfg = config.modules.dev.nvim.plugins.surround;
in {
  options.modules.dev.nvim.plugins.surround = {
    enable = lib.mkEnableOption "Enable surround";
  };
  config = lib.mkIf cfg.enable {
    programs.nixvim.plugins = {
      vim-surround.enable = true;
    };
  };
}
