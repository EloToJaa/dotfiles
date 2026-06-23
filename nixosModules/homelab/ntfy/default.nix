{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.ntfy;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  vars = config.clan.core.vars.generators.${cfg.name};
in {
  options.modules.homelab.ntfy = {
    enable = lib.mkEnableOption "Enable ntfy";
    name = lib.mkOption {
      type = lib.types.str;
      default = "ntfy-sh";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "ntfy";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.main;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3005;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
  };
  config = lib.mkIf cfg.enable {
    services.ntfy-sh = {
      inherit (cfg) group;
      enable = true;
      package = pkgs.unstable.ntfy-sh;
      user = cfg.name;
      settings = {
        listen-http = "127.0.0.1:${toString cfg.port}";
        cache-file = "${cfg.dataDir}/cache.db";
        attachment-cache-dir = "${cfg.dataDir}/attachments";
        base-url = "https://${domain}";
        behind-proxy = true;
      };
    };
    systemd.services.paperless = {
      environment = {
        NTFY_AUTH_FILE = "${cfg.dataDir}/auth.db";
        NTFY_ENABLE_LOGIN = "true";
        NTFY_AUTH_DEFAULT_ACCESS = "deny-all";
      };
      serviceConfig = {
        Group = cfg.group;
        UMask = lib.mkForce homelab.defaultUMask;
        EnvironmentFile = vars.files.env.path;
        StateDirectory = lib.mkForce null;
        DynamicUser = lib.mkForce false;
        ProtectSystem = lib.mkForce "off";
      };
    };
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
    ];

    services.nginx.virtualHosts.${domain} = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };

    clan.core.state.ntfy = {
      folders = [
        cfg.dataDir
      ];
      preBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl stop ntfy-sh.service
      '';

      postBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl start ntfy-sh.service
      '';
    };

    users.users.${cfg.name} = {
      isSystemUser = true;
      description = cfg.name;
      group = lib.mkForce cfg.group;
    };

    clan.core.vars.generators.${cfg.name} = {
      prompts.authusers = {
        description = "ntfy auth users value";
        type = "hidden";
      };
      files.env = {
        owner = cfg.name;
        secret = true;
      };
      script = ''
                mkdir -p "$out"
                printf 'NTFY_AUTH_USERS=%s
        ' "$(cat "$prompts/authusers")" > "$out/env"
      '';
    };
  };
}
