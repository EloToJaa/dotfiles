{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.home.nvim.languages.markdown;
in {
  options.modules.home.nvim.languages.markdown = {
    enable = lib.mkEnableOption "Enable markdown";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      prettierd
      markdown-oxide
    ];

    programs.nixvim = {
      lsp.servers.markdown_oxide = {
        enable = true;
        package = null;
      };
      plugins = {
        conform-nvim.settings.formatters_by_ft = {
          markdown = ["prettierd"];
        };
        treesitter.grammarPackages = with pkgs.unstable.vimPlugins.nvim-treesitter.builtGrammars; [
          markdown
        ];
      };
    };

    programs.opencode.settings.lsp.markdown_oxide = {
      command = ["markdown-oxide"];
      extensions = [".md"];
    };
  };
}
