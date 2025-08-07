{
  pkgs,
  inputs,
  variables,
  ...
}: let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in {
  # home.packages = with pkgs.unstable; [spotube];

  imports = [inputs.spicetify-nix.homeManagerModules.default];

  programs.spicetify = {
    enable = true;

    enabledExtensions = with spicePkgs.extensions; [
      adblock
      shuffle # shuffle+ (special characters are sanitized out of extension names)
    ];

    theme = spicePkgs.themes.catppuccin;
    colorScheme = variables.catppuccin.flavor;
  };
}
