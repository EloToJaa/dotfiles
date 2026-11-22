{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.modules.homelab.qbittorrent;
in {
  config = lib.mkIf cfg.enable {
    modules.homelab.prometheus.scrapeTargets = [
      {
        job_name = "qbittorrent";
        address = "127.0.0.1:${toString cfg.exporterPort}";
      }
    ];

    systemd.services."prometheus-${cfg.name}-exporter" = {
      description = "Prometheus exporter for qBittorrent";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      environment = {
        EXPORTER_HOST = "127.0.0.1";
        EXPORTER_PORT = toString cfg.exporterPort;
        QBITTORRENT_BASE_URL = "http://127.0.0.1:${toString cfg.port}";
      };
      serviceConfig = {
        ExecStart = lib.getExe pkgs.unstable.prometheus-qbittorrent-exporter;
        EnvironmentFile = config.clan.core.vars.generators."${cfg.name}-exporter".files.env.path;
        DynamicUser = true;
        Restart = "always";
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = ["AF_INET" "AF_INET6"];
      };
    };

    clan.core.vars.generators."${cfg.name}-exporter" = {
      prompts.apikey = {
        description = "qBittorrent WebUI API key for the Prometheus exporter (Options > WebUI > API keys)";
        type = "hidden";
      };
      files.env = {};
      script = ''
        printf 'QBITTORRENT_API_KEY=%s\n' "$(cat "$prompts/apikey")" > "$out/env"
      '';
    };
  };
}
