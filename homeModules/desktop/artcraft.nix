{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.modules.desktop.artcraft;
  craftapps = inputs.craftapps.packages.${pkgs.stdenv.hostPlatform.system};
in {
  options.modules.desktop.artcraft = {
    photocraft.enable = lib.mkEnableOption "Enable photocraft"; # image editor
    wordcraft.enable = lib.mkEnableOption "Enable wordcraft"; # word processor
  };
  config = {
    home.packages =
      lib.optional cfg.photocraft.enable craftapps.photocraft
      ++ lib.optional cfg.wordcraft.enable craftapps.wordcraft;
  };
}
