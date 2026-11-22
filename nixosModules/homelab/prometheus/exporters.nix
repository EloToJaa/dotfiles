{
  config,
  lib,
  ...
}: let
  inherit (config.modules) homelab;
  inherit (config.services.prometheus) exporters;
  hasDisks = config.modules.base.smartd.enable;
in {
  config = lib.mkIf homelab.enable {
    services.prometheus.exporters = {
      systemd = {
        enable = true;
        listenAddress = "127.0.0.1";
      };
      smartctl = {
        enable = hasDisks;
        listenAddress = "127.0.0.1";
      };
    };

    modules.homelab.prometheus.scrapeTargets =
      [
        {
          job_name = "systemd";
          address = "127.0.0.1:${toString exporters.systemd.port}";
        }
      ]
      ++ lib.optional hasDisks {
        job_name = "smartctl";
        address = "127.0.0.1:${toString exporters.smartctl.port}";
      };
  };
}
