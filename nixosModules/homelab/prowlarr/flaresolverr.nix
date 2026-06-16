{
  config,
  lib,
  ...
}: let
  cfg = config.modules.homelab.prowlarr.flaresolverr;
in {
  options.modules.homelab.prowlarr.flaresolverr = {
    enable = lib.mkEnableOption "Enable flaresolverr";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8191;
    };
  };
  config = lib.mkIf cfg.enable {
    # services.flaresolverr = {
    #   enable = true;
    #   package = pkgs.unstable.flaresolverr;
    #   inherit (cfg) port;
    # };
    # systemd.services.flaresolverr.environment = {
    #   HOST = "127.0.0.1";
    # };
    virtualisation.oci-containers.containers.flaresolverr = {
      image = "flaresolverr/flaresolverr:v3.5.0";
      extraOptions = ["--network=host"];
      serviceName = "flaresolverr";
      environment = {
        HOST = "127.0.0.1";
        PORT = toString cfg.port;
      };
    };
  };
}
