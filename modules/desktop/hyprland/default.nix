{inputs, ...}: {
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
