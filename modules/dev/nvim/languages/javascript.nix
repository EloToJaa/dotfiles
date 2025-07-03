{pkgs, ...}: {
  home.packages = with pkgs; [
    eslint_d
    prettierd

    nodejs
    bun
    npm-check-updates
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
      treesitter.settings.ensure_installed = [
        "javascript"
        "typescript"
        "astro"
        "svelte"
        "tsx"
        "html"
        "css"
      ];
    };
  };
}
