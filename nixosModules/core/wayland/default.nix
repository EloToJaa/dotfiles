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
    ./umbriel.nix
  ];

  options.modules.core.wayland = {
    enable = lib.mkEnableOption "Enable wayland module";
    hyprland.enable = lib.mkEnableOption "Enable hyprland";
    niri.enable = lib.mkEnableOption "Enable niri";
    umbriel.enable = lib.mkEnableOption "Enable umbriel";
    greeter = lib.mkOption {
      type = lib.types.enum ["dms" "noctalia"];
      default = "noctalia";
      description = "greetd greeter to use: DankMaterialShell's or Noctalia's";
    };
  };

  config = lib.mkIf (config.modules.core.enable && cfg.enable) {
    environment.pathsToLink = ["/share/applications" "/share/xdg-desktop-portal"];
    services = {
      dbus.implementation = "broker";
      power-profiles-daemon.enable = true;
    };
    users.users.${config.settings.username}.extraGroups = ["input"];
  };
}
