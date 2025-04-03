{
  inputs,
  variables,
  ...
}: {
  imports = [inputs.catppuccin.homeModules.catppuccin];
  catppuccin = {
    enable = true;
    flavor = "${variables.catppuccin.flavor}";
    accent = "${variables.catppuccin.accent}";
  };
}
