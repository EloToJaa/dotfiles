{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.home.nvim.languages.zig;
in {
  options.modules.home.nvim.languages.zig = {
    enable = lib.mkEnableOption "Enable zig";
  };
  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      lsp.servers.zls = {
        enable = true;
      };
      plugins = {
        treesitter.grammarPackages = with pkgs.unstable.vimPlugins.nvim-treesitter.builtGrammars; [
          zig
        ];
      };
    };
  };
}
