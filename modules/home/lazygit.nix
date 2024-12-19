{variables, ...}: {
  programs.lazygit = {
    enable = true;
  };
  catppuccin.lazygit = {
    # enable = true;
    flavor = "${variables.catppuccin.flavor}";
    accent = "${variables.catppuccin.accent}";
  };
}
