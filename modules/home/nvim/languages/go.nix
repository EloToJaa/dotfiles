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
      treesitter.settings.ensure_installed = [
        "go"
      ];
    };
  };
}
