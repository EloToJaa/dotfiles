{pkgs, ...}: {
  home.packages = with pkgs.unstable; [
    prettierd
  ];

  programs.nixvim = {
    lsp.servers.markdown_oxide = {
      enable = true;
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
}
