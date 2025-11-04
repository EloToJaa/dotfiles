{
  inputs,
  lib,
  ...
}: {
  options.modules.desktop.hyprland = {
    enable = lib.mkEnableOption "Enable hyprland";
  };
  imports = [
    ./hyprland.nix
    ./config.nix
    ./variables.nix
    inputs.hyprland.homeManagerModules.default
  ];
}
