{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.dev.nvim.languages.javascript;
in {
  options.modules.dev.nvim.languages.javascript = {
    enable = lib.mkEnableOption "Enable javascript";
  };
  config = lib.mkIf cfg.enable {
    # home.packages = with pkgs.unstable; [
    #   oxlint
    #   oxfmt
    #   typescript
    # ];

    programs.nixvim = {
      lsp.servers = {
        tsgo = {
          enable = true;
          package = null;
        };
        astro = {
          enable = true;
          package = null;
        };
        svelte = {
          enable = true;
          package = null;
        };
        tailwindcss = {
          enable = true;
          package = null;
        };
        html = {
          enable = true;
          package = null;
        };
        cssls = {
          enable = true;
          package = null;
        };
      };
      plugins = let
        formatter = "oxfmt";
        linter = "oxlint";
      in {
        lint.lintersByFt = {
          javascript = [linter];
          typescript = [linter];
          javascriptreact = [linter];
          typescriptreact = [linter];
          svelte = [linter];
          astro = [linter];
        };
        conform-nvim.settings.formatters_by_ft = {
          javascript = [formatter];
          typescript = [formatter];
          javascriptreact = [formatter];
          typescriptreact = [formatter];
          svelte = [formatter];
          astro = [formatter];
          html = [formatter];
          css = [formatter];
        };
        treesitter.grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
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
