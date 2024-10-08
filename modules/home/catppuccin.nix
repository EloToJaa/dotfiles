{ inputs, variables, ... }:
{
  imports = [ inputs.catppuccin.homeManagerModules.catppuccin ];
  catppuccin = {
    enable = true;
    flavor = "${variables.catppuccin.flavor}";
    accent = "${variables.catppuccin.accent}";
  };
}
