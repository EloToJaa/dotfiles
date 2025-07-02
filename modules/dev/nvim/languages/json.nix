{
  programs.nixvim = {
    lsp.servers.jsonls = {
      enable = true;
    };
    plugins = {
      treesitter.settings.ensure_installed = [
        "json"
      ];
    };
  };
}
