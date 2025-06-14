{variables, ...}: {
  programs.nvf.settings.vim.theme = {
    enable = true;
    name = "catppuccin";
    style = variables.catppuccin.flavor;
    transparent = true;
  };
}
