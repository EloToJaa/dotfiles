{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.dev.nvim.languages.yaml;
in {
  options.modules.dev.nvim.languages.yaml = {
    enable = lib.mkEnableOption "Enable yaml";
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
