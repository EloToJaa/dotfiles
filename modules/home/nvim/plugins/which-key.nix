{
  config,
  lib,
  ...
}: let
  cfg = config.modules.home.nvim.plugins.which-key;
in {
  options.modules.home.nvim.plugins.which-key = {
    enable = lib.mkEnableOption "Enable which-key";
  };
  programs.nixvim.plugins.which-key = {
    inherit (cfg) enable;
  };
}
