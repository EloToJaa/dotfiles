{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.desktop.zen;
in {
  options.modules.desktop.zen = {
    enable = lib.mkEnableOption "Enable zen";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
