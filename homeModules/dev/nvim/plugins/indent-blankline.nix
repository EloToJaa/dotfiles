{
  lib,
  config,
  ...
}: let
  cfg = config.modules.dev.nvim.plugins.indent-blankline;
in {
  options.modules.dev.nvim.plugins.indent-blankline = {
    enable = lib.mkEnableOption "Enable indent-blankline";
  };
  config = lib.mkIf cfg.enable {
    programs.nixvim.plugins.indent-blankline = {
      enable = true;
      settings.indent.char = "┊";
    };
  };
}
