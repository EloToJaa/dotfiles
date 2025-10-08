{pkgs, ...}: {
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
}
