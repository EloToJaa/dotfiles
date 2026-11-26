{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = homelab.cliproxyapi;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "cliproxyapi";
    port = 8317;
    description = "Enable CLIProxyAPI";
    domainName = "hub";
    glance.icon = "mdi:api";
    gatus = {
      name = "CLI Proxy API";
      group = "ai";
      conditions = ["[STATUS] < 400"];
    };
  };
  secrets = config.clan.core.vars.generators.cliproxyapi;
in {
  imports = [./service.nix];

  options.modules.homelab.cliproxyapi =
    service.options
    // {
      archiveDir = lib.mkOption {
        type = lib.types.path;
        default = "${homelab.varDataDir}${cfg.name}-archive";
        description = "Directory where compressed request logs are archived.";
      };
    };

  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
      services.cliproxyapi = {
        enable = true;
        package = pkgs.llm-agents.cli-proxy-api;
        user = cfg.name;
        group = cfg.name;
        inherit (cfg) dataDir;
        settings = {
          server = {
            host = "127.0.0.1";
            inherit (cfg) port;
            trusted-proxies = ["127.0.0.1"];
          };
          access.api-keys = [{_secret = secrets.files.api-key.path;}];
          management = {
            allow-remote = true;
            secret-key._secret = secrets.files.management-key.path;
          };
          observability.logs = {
            logging-to-file = true;
            request-log = true;
            # safety net only; request logs are moved to archiveDir hourly
            logs-max-total-size-mb = 10240;
          };
          observability.usage.usage-statistics-enabled = true;
        };
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.archiveDir} 0700 ${cfg.name} ${cfg.name} - -"
      ];

      # Move finished request logs out of the size cleaner's reach into dated, compressed archives
      systemd.services.cliproxyapi-log-archive = {
        description = "Archive CLIProxyAPI request logs";
        startAt = "hourly";
        path = [pkgs.coreutils pkgs.findutils pkgs.zstd];
        script = ''
          find ${lib.escapeShellArg "${cfg.dataDir}/logs"} -maxdepth 1 -type f -name '*.log' \
            ! -name main.log -mmin +30 -print0 |
            while IFS= read -r -d "" file; do
              dest=${lib.escapeShellArg cfg.archiveDir}/"$(date -r "$file" +%Y/%m/%d)"
              mkdir -p "$dest"
              zstd -q -19 --rm -o "$dest/$(basename "$file").zst" "$file"
            done
        '';
        serviceConfig = {
          Type = "oneshot";
          User = cfg.name;
          Group = cfg.name;
          UMask = "0077";
          NoNewPrivileges = true;
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectHome = true;
          ProtectSystem = "strict";
          ReadWritePaths = ["-${cfg.dataDir}/logs" cfg.archiveDir];
        };
      };

      clan.core.vars.generators.cliproxyapi = {
        files = {
          api-key = {
            owner = cfg.name;
            group = cfg.name;
          };
          management-key = {
            owner = cfg.name;
            group = cfg.name;
          };
        };
        runtimeInputs = [pkgs.pwgen];
        script = ''
          mkdir -p "$out"
          pwgen -s 64 1 > "$out/api-key"
          pwgen -s 64 1 > "$out/management-key"
        '';
      };

      services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}".locations."/".extraConfig = ''
        proxy_buffering off;
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
      '';

      clan.core.state.cliproxyapi = {
        folders = [cfg.dataDir];
        preBackupScript = ''
          ${config.systemd.package}/bin/systemctl stop cliproxyapi.service
        '';
        postBackupScript = ''
          ${config.systemd.package}/bin/systemctl start cliproxyapi.service
        '';
      };

      clan.core.state.cliproxyapi-archive.folders = [cfg.archiveDir];
    })
  ];
}
