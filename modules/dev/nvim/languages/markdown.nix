{pkgs, ...}: {
  home.packages = with pkgs; [
    prettierd
  ];

  programs.nixvim = {
    lsp.servers.markdown_oxide = {
      enable = true;
    };
    plugins = {
      treesitter.settings.ensure_installed = [
        "markdown"
      ];
      conform-nvim.settings.formatters_by_ft = {
        markdown = ["prettierd"];
      };
    };
  };
}
