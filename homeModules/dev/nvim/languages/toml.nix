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
    home.packages = with pkgs.unstable; [
      taplo
      oxfmt
    ];
    programs.nixvim = {
      lsp.servers.taplo = {
        enable = true;
        package = null;
      };
      plugins = {
        conform-nvim.settings.formatters_by_ft = {
          toml = ["oxfmt"];
        };
        treesitter.grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          toml
        ];
      };
    };
  };
}
