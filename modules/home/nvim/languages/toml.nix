{
  programs.nixvim = {
    lsp.servers.taplo = {
      enable = true;
    };
    plugins = {
      treesitter.settings.ensure_installed = [
        "toml"
      ];
    };
  };
}
