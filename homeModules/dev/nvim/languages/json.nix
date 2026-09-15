{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.dev.nvim.languages.json;
in {
  options.modules.dev.nvim.languages.json = {
    enable = lib.mkEnableOption "Enable json";
  };
  config = lib.mkIf cfg.enable {
    # home.packages = with pkgs.unstable; [
    #   prettierd
    # ];

    programs.nixvim = {
      lsp.servers.jsonls = {
        enable = true;
        package = null;
      };
      plugins = {
        conform-nvim.settings.formatters_by_ft = {
          json = ["oxfmt"];
        };
        treesitter.grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          json
        ];
      };
    };
  };
}
