{variables, ...}: {
  programs.nixvim = {
    colorscheme = "catppuccin";
    colorschemes.catppuccin = {
      enable = true;

      settings = {
        flavour = "mocha";
        disable_underline = true;
        # integrations = {};
      };
    };
  };
}
