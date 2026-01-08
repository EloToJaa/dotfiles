{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.home.nvim.languages.json;
in {
  options.modules.home.nvim.languages.json = {
    enable = lib.mkEnableOption "Enable json";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      prettierd
    ];

    programs.nixvim = {
      lsp.servers.jsonls = {
        enable = true;
      };
      plugins = {
        conform-nvim.settings.formatters_by_ft = {
          json = ["prettierd"];
        };
        treesitter.grammarPackages = with pkgs.unstable.vimPlugins.nvim-treesitter.builtGrammars; [
          json
        ];
      };
    };
  };
}
