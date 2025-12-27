{
  inputs,
  lib,
  ...
}: {
  options.modules.desktop.hyprland = {
    enable = lib.mkEnableOption "Enable hyprland";
  };
  imports = [
    ./bindings.nix
    ./exec-once.nix
    ./hyprland.nix
    ./layerrules.nix
    ./monitors.nix
    ./settings.nix
    ./variables.nix
    ./windowrules.nix
    inputs.hyprland.homeManagerModules.default
  ];
}
