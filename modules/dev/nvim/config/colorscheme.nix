{variables, ...}: {
  programs.nixvim.colorschemes.catppuccin = {
    enable = true;

    settings = {
      flavour = variables.catppuccin.flavour;
      disable_underline = true;
      # integrations = {};
    };
  };
}
