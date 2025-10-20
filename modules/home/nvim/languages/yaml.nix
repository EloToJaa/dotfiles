{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.home.nvim.languages.xml;
in {
  options.modules.home.nvim.languages.xml = {
    enable = lib.mkEnableOption "Enable xml";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      prettierd
    ];

    programs.nixvim = {
      lsp.servers.yamlls = {
        enable = true;
      };
      plugins = {
        conform-nvim.settings.formatters_by_ft = {
          yaml = ["prettierd"];
        };
        treesitter.grammarPackages = with pkgs.unstable.vimPlugins.nvim-treesitter.builtGrammars; [
          yaml
        ];
      };
    };
  };
}
