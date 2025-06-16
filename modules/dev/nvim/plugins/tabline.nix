{
  programs.nvf.settings.vim.tabline.nvimBufferline = {
    enable = true;
    setupOpts.options = {
      mode = "tabs";
      numbers = "ordinal";
      # style_preset = "minimal";
      show_tab_indicators = false;
      show_close_icons = false;
      sort_by = "id";
    };
  };
}
