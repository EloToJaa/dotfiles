{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.home;
in {
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      ## CLI utility
      gtrash # rm replacement, put deleted files in system trash
      killall
      man-pages # extra man pages
      openssl
      usbutils

      dig
    ];
  };
}
