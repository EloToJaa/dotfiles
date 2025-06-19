{variables, ...}: {
  programs.nixvim.colorschemes.catppuccin = {
    enable = true;

    settings = {
      flavour = variables.catppuccin.flavor;
      disable_underline = true;
      # integrations = {};
    };
  };
}
