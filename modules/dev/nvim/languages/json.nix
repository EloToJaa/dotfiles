{pkgs, ...}: {
  home.packages = with pkgs; [
    prettierd
  ];

  programs.nixvim = {
    lsp.servers.jsonls = {
      enable = true;
    };
    plugins = {
      treesitter.settings.ensure_installed = [
        "json"
      ];
      conform-nvim.settings.formatters_by_ft = {
        json = ["prettierd"];
      };
    };
  };
}
