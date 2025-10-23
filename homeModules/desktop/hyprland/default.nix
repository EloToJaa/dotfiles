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
    ./hyprlock.nix
    ./satty.nix
    ./variables.nix
    ./wlogout.nix
    inputs.hyprland.homeManagerModules.default
  ];
}
