{
  config,
  lib,
  ...
}: let
  cfg = config.modules.dev.nvim;
in {
  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      colorscheme = "catppuccin";
      colorschemes.catppuccin = {
        enable = true;
        autoLoad = true;

        settings = {
          flavour = "mocha";
          disable_underline = true;
          transparent_background = true;
          # integrations = {};
        };
      };
    };
  };
}
