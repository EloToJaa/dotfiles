{
  programs.nixvim = {
    lsp.servers.zls = {
      enable = true;
    };
    plugins = {
      treesitter.settings.ensure_installed = [
        "zig"
      ];
    };
  };
}
