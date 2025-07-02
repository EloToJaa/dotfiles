{
  programs.nixvim = {
    lsp.servers.markdown_oxide = {
      enable = true;
    };
    plugins = {
      treesitter.settings.ensure_installed = [
        "markdown"
      ];
    };
  };
}
