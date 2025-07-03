{pkgs, ...}: {
  home.packages = with pkgs; [
    prettierd
  ];

  programs.nixvim = {
    lsp.servers.yamlls = {
      enable = true;
    };
    plugins = {
      treesitter.settings.ensure_installed = [
        "yaml"
      ];
      conform-nvim.settings.formatters_by_ft = {
        yaml = ["prettierd"];
      };
    };
  };
}
