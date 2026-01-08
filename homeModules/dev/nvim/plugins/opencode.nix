{
  lib,
  config,
  ...
}: let
  cfg = config.modules.dev.nvim.plugins.opencode;
in {
  options.modules.dev.nvim.plugins.opencode = {
    enable = lib.mkEnableOption "Enable opencode";
  };
  config = lib.mkIf (cfg.enable && config.modules.dev.opencode.enable) {
    programs.nixvim.plugins = {
      opencode = {
        enable = true;
        settings = {
        };
      };
      snacks = {
        enable = true;
        settings = {
          input.enable = true;
          picker.enable = true;
          terminal.enable = true;
        };
      };
    };
  };
}
