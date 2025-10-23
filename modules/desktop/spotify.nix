{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  inherit (config.settings) catppuccin;
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  cfg = config.modules.desktop.spotify;
in {
  options.modules.desktop.spotify = {
    enable = lib.mkEnableOption "Enable spotify";
  };
  imports = [inputs.spicetify-nix.homeManagerModules.default];
  config = lib.mkIf cfg.enable {
    # home.packages = with pkgs.unstable; [spotube];

    programs.spicetify = {
      enable = true;

      enabledExtensions = with spicePkgs.extensions; [
        adblock
        shuffle # shuffle+ (special characters are sanitized out of extension names)
      ];

      theme = spicePkgs.themes.catppuccin;
      colorScheme = catppuccin.flavor;
    };
  };
}
