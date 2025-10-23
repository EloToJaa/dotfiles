{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.dev;
in {
  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      ANDROID_HOME = "${config.home.homeDirectory}/Android/Sdk";
      SHELL = "${pkgs.unstable.zsh}/bin/zsh";
    };
  };
}
