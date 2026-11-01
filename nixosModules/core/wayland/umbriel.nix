{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.modules.core.wayland;
in {
  imports = [inputs.umbriel.nixosModules.default];

  config = lib.mkIf (config.modules.core.enable && cfg.enable && cfg.umbriel.enable) {
    programs.umbriel.enable = true;
  };
}
