{pkgs, ...}: {
  home.packages = with pkgs.unstable; [
    gofumpt
  ];

  programs.nixvim = {
    lsp.servers.gopls = {
      enable = true;
      settings = {
        analyses.unusedparams = true;
        staticcheck = true;
        gofumpt = true;
      };
    };
    plugins = {
      conform-nvim.settings.formatters_by_ft = {
        go = ["gofumpt"];
      };
      treesitter.grammarPackages = with pkgs.unstable.vimPlugins.nvim-treesitter.builtGrammars; [
        go
      ];
    };
  };
}
