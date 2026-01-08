{
  config,
  lib,
  ...
}: let
  cfg = config.modules.dev.nvim.plugins.which-key;
in {
  options.modules.dev.nvim.plugins.which-key = {
    enable = lib.mkEnableOption "Enable which-key";
  };
  config = lib.mkIf cfg.enable {
    programs.nixvim.plugins.which-key = {
      enable = true;
    };
  };
}
