{
  programs.nvf.settings.vim.lsp = {
    enable = true;
    formatOnSave = true;
    trouble = {
      enable = true;

      setupOpts.focus = true;
    };
    lspSignature.enable = true;
    lspconfig.enable = true;
    # null-ls.enable = false;
    inlayHints.enable = true;
  };
}
