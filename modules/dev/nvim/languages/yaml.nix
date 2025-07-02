{
  programs.nixvim = {
    lsp.servers.yamlls = {
      enable = true;
    };
    plugins = {
      treesitter.settings.ensure_installed = [
        "yaml"
      ];
    };
  };
}
