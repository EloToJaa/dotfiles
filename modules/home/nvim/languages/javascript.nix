{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.home.nvim.languages.javascript;
in {
  options.modules.home.nvim.languages.javascript = {
    enable = lib.mkEnableOption "Enable javascript";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      eslint_d
      prettierd
    ];

    programs.nixvim = {
      lsp.servers = {
        ts_ls.enable = true;
        astro.enable = true;
        svelte.enable = true;
        tailwindcss.enable = true;
        html.enable = true;
        cssls.enable = true;
      };
      plugins = {
        lint.lintersByFt = {
          javascript = ["eslint_d"];
          typescript = ["eslint_d"];
          javascriptreact = ["eslint_d"];
          typescriptreact = ["eslint_d"];
          svelte = ["eslint_d"];
          astro = ["eslint_d"];
        };
        conform-nvim.settings.formatters_by_ft = {
          javascript = ["prettierd"];
          typescript = ["prettierd"];
          javascriptreact = ["prettierd"];
          typescriptreact = ["prettierd"];
          svelte = ["prettierd"];
          astro = ["prettierd"];
          html = ["prettierd"];
          css = ["prettierd"];
        };
        treesitter.grammarPackages = with pkgs.unstable.vimPlugins.nvim-treesitter.builtGrammars; [
          javascript
          typescript
          astro
          svelte
          tsx
          html
          css
        ];
      };
    };
  };
}
