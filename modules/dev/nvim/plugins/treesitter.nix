{
  programs.nixvim.plugins.treesitter = {
    enable = true;
    settings = {
      highlight.enable = true;
      indent.enable = true;
      incremental_selection.enable = true;

      auto_install = true;
    };
  };
}
