{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.dev.nvim.languages.toml;
in {
  options.modules.dev.nvim.languages.toml = {
    enable = lib.mkEnableOption "Enable toml";
  };
  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      lsp.servers.taplo = {
        enable = true;
      };
      plugins = {
        treesitter.grammarPackages = with pkgs.unstable.vimPlugins.nvim-treesitter.builtGrammars; [
          toml
        ];
      };
    };
  };
}
