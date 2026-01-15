{
  pkgs,
  inputs,
  config,
  lib,
  settings,
  ...
}: let
  inherit (settings) catppuccin;
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
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
