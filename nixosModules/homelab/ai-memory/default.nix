{
  lib,
  config,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = homelab.ai-memory;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "ai-memory";
    port = 49374;
    description = "Enable ai-memory, the shared long-term memory server for AI agents";
    domainName = "memory";
    proxyWebsockets = false;
    glance.icon = "mdi:brain";
    gatus = {
      name = "ai-memory";
      group = "ai";
      path = "/healthz";
    };
  };
  secrets = config.clan.core.vars.generators.ai-memory-server;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
in {
  imports = [./service.nix];

  options.modules.homelab.ai-memory = service.options;

  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
      services.ai-memory = {
        enable = true;
        user = cfg.name;
        group = cfg.name;
        inherit (cfg) dataDir port;
        enableWeb = true;
        environmentFile = secrets.files.env.path;
        settings = {
          allowed_hosts = [domain "localhost" "127.0.0.1" "::1"];
          log_level = "info";
        };
      };

      clan.core.vars.generators.ai-memory-server = {
        share = true;
        dependencies = ["ai-memory"];
        files.env = {
          owner = cfg.name;
          group = cfg.name;
        };
        script = ''
          printf 'AI_MEMORY_AUTH_TOKEN=%s\n' "$(cat "$in/ai-memory/auth-token")" > "$out/env"
        '';
      };

      services.nginx.virtualHosts.${domain}.locations."/".extraConfig = ''
        proxy_buffering off;
        proxy_read_timeout 600s;
        client_max_body_size 64m;
      '';

      clan.core.state.ai-memory = {
        folders = [cfg.dataDir];
        preBackupScript = ''
          ${config.systemd.package}/bin/systemctl stop ai-memory.service
        '';
        postBackupScript = ''
          ${config.systemd.package}/bin/systemctl start ai-memory.service
        '';
      };
    })
  ];
}
