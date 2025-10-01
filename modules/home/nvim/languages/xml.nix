{
  programs.nixvim = {
    lsp.servers.lemminx = {
      enable = true;
    };
    plugins = {
      treesitter.settings.ensure_installed = [
        "xml"
      ];
    };
  };
}
