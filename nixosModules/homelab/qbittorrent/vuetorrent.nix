{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.vuetorrent;
in {
  options.services.vuetorrent = {
    enable = lib.mkEnableOption (lib.mdDoc "vuetorrent");
    package = lib.mkPackageOption pkgs "vuetorrent" {};
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [cfg.package];

    environment.etc."vuetorrent" = {
      source = cfg.package;
      target = "vuetorrent";
    };
  };
}
