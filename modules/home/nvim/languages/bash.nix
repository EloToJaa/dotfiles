{pkgs, ...}: {
  home.packages = with pkgs.unstable; [
    shfmt
  ];

  programs.nixvim = {
    lsp.servers.bashls = {
      enable = true;
      settings = {
        cmd = [
          "bash-language-server"
          "start"
        ];
        filetypes = ["sh" "zsh" "bash"];
      };
    };
    plugins = {
      conform-nvim.settings.formatters_by_ft = {
        sh = ["shfmt"];
        bash = ["shfmt"];
        zsh = ["shfmt"];
      };
      treesitter.grammarPackages = with pkgs.unstable.vimPlugins.nvim-treesitter.builtGrammars; [
        bash
      ];
    };
  };
}
