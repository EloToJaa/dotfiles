{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.homelab.prometheus.exportarr;
in {
  options.modules.homelab.prometheus.exportarr = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        port = lib.mkOption {
          type = lib.types.port;
          description = "Loopback port the exporter listens on, unique per app.";
        };
        url = lib.mkOption {
          type = lib.types.str;
          description = "Base URL of the app the exporter queries.";
        };
        apiKeyFile = lib.mkOption {
          type = lib.types.path;
          description = "File holding the app's API key.";
        };
      };
    });
    default = {};
    description = "Exportarr instances keyed by exportarr app name (sonarr, radarr, prowlarr, bazarr). Each *arr module appends its own.";
  };

  config = {
    services.prometheus.exporters = lib.mapAttrs' (app: exporter:
      lib.nameValuePair "exportarr-${app}" {
        enable = true;
        inherit (exporter) port url apiKeyFile;
        listenAddress = "127.0.0.1";
        package = pkgs.unstable.exportarr;
        environment = {
          INTERFACE = "127.0.0.1";
          LOG_LEVEL = "warn";
        };
      })
    cfg;

    modules.homelab.prometheus.scrapeTargets =
      lib.mapAttrsToList (app: exporter: {
        job_name = "exportarr-${app}";
        address = "127.0.0.1:${toString exporter.port}";
      })
      cfg;
  };
}
