{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.dev;
in {
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      ## CLI utility
      deploy-rs
      xh
      nurl
    ];
  };
}
