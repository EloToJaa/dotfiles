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
  programs.nixvim.plugins.lint = {
    inherit (cfg) enable;
  };
}
