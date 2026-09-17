{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.modules.core.wayland;
  inherit (config.settings) username;
  luaFiles = [
    "animations.lua"
    "bindings.lua"
    "hyprland.lua"
    "layers.lua"
    "settings.lua"
    "startup.lua"
    "themes/catppuccin.lua"
    "windowrules.lua"
  ];
  fileNames = map (name: "hypr/${name}") luaFiles;
in {
  imports = [inputs.hjem.nixosModules.default];

  config = lib.mkIf (cfg.enable && cfg.hyprland.enable) {
    # Home Manager renders the Lua; Hjem owns the files in ~/.config/hypr.
    home-manager.users.${username}.xdg.configFile = lib.genAttrs fileNames (_: {
      enable = lib.mkForce false;
    });

    hjem.users.${username} = {
      enable = true;
      xdg.config.files = lib.genAttrs fileNames (name: {
        source = config.home-manager.users.${username}.xdg.configFile.${name}.source;
        clobber = true;
      });
    };
  };
}
