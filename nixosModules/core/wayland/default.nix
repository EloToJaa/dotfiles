{
  lib,
  config,
  ...
}: let
  cfg = config.modules.core.wayland;
in {
  imports = [
    ./greeter.nix
    ./hyprland.nix
    ./niri.nix
  ];

  options.modules.core.wayland = {
    enable = lib.mkEnableOption "Enable wayland module";
    hyprland.enable = lib.mkEnableOption "Enable hyprland";
    niri.enable = lib.mkEnableOption "Enable niri";
  };

  config = lib.mkIf cfg.enable {
    environment.pathsToLink = ["/share/applications" "/share/xdg-desktop-portal"];
    services = {
      dbus.implementation = "broker";
      power-profiles-daemon.enable = true;
    };
    boot.initrd.kernelModules = ["amdgpu"];
  };
}
