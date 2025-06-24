{
  programs.nixvim = {
    plugins.lspconfig = {
      enable = true;
    };
    lsp = {
      inlayHints.enable = true;
    };
  };
}
