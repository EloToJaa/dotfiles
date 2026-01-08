{
  lib,
  config,
  ...
}: let
  cfg = config.modules.home.nvim.plugins.lz-n;
in {
  options.modules.home.nvim.plugins.lz-n = {
    enable = lib.mkEnableOption "Enable lz-n";
  };
  config = lib.mkIf cfg.enable {
    programs.nixvim.plugins.lz-n = {
      enable = true;
    };
  };
}
