{
  lib,
  config,
  ...
}: let
  cfg = config.modules.dev.nvim.plugins.lz-n;
in {
  options.modules.dev.nvim.plugins.lz-n = {
    enable = lib.mkEnableOption "Enable lz-n";
  };
  config = lib.mkIf cfg.enable {
    programs.nixvim.plugins.lz-n = {
      enable = true;
    };
  };
}
