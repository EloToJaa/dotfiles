{variables, ...}: {
  programs.nixvim = {
    colorscheme = "catppuccin";
    colorschemes.catppuccin = {
    enable = true;

    settings = {
      flavour = variables.catppuccin.flavor;
      disable_underline = true;
      # integrations = {};
    };
  };
  };
}
