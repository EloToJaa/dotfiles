{
  programs.nixvim.plugins.conform-nvim = {
    enable = true;
    settings.format_on_save = {
      lsp_fallback = true;
      async = false;
      timeout = 1000;
    };
  };
}
