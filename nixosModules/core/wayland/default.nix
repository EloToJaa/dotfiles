{
  lib,
  config,
  ...
}: let
  cfg = config.modules.core.wayland;
in {
  imports = [
    ./greeter.nix
    ./umbriel.nix
  ];

  options.modules.core.wayland = {
    enable = lib.mkEnableOption "Enable wayland module";
    umbriel.enable = lib.mkEnableOption "Enable umbriel";
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
