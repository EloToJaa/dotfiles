{pkgs, ...}: {
  home.packages = with pkgs; [
    go
    gofumpt

    sqlc
    goose
  ];

  programs.nixvim = {
    lsp.servers.gopls = {
      enable = true;
    };
    plugins = {
      conform-nvim.settings.formatters_by_ft = {
        go = ["gofumpt"];
      };
      treesitter.settings.ensure_installed = [
        "go"
      ];
    };
  };
}
