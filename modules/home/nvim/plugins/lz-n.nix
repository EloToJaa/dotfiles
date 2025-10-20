{
  lib,
  config,
}: let
  cfg = config.modules.home.nvim.plugins.lz-n;
in {
  options.modules.home.nvim.plugins.lz-n = {
    enable = lib.mkEnableOption "Enable lz-n";
  };
  programs.nixvim.plugins.lz-n = {
    inherit (cfg) enable;
  };
}
