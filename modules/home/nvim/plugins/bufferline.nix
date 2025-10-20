{
  config,
  lib,
  ...
}: let
  cfg = config.modules.home.nvim.plugins.bufferline;
in {
  options.modules.home.nvim.plugins.bufferline = {
    enable = lib.mkEnableOption "Enable bufferline";
  };
  config = lib.mkIf cfg.enable {
    programs.nixvim.plugins.bufferline = {
      enable = true;
      settings.options = {
        mode = "tabs";
        numbers = "ordinal";
      };
    };
  };
}
