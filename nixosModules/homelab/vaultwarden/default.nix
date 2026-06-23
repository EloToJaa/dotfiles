{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.vaultwarden;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  vars = config.clan.core.vars.generators.${cfg.name};
in {
  options.modules.homelab.vaultwarden = {
    enable = lib.mkEnableOption "Enable vaultwarden";
    name = lib.mkOption {
      type = lib.types.str;
      default = "vaultwarden";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "pwd";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.main;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8222;
    };
  };
  imports = [
    ./auth.nix
  ];
  config = lib.mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      package = pkgs.unstable.vaultwarden;
      dbBackend = "postgresql";
      environmentFile = vars.files.env.path;
      config = {
        domain = "https://${domain}";
        rocketPort = cfg.port;
        signupsAllowed = false;
        invitationsAllowed = false;
        websocketEnabled = true;
      };
    };
    systemd.services.vaultwarden.serviceConfig = {
      Group = lib.mkForce cfg.group;
      UMask = lib.mkForce homelab.defaultUMask;
    };
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
    ];

    services.nginx.virtualHosts.${domain} = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    };

    clan.core.state.vaultwarden = {
      folders = [
        cfg.dataDir
      ];
      preBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl stop vaultwarden.service
      '';

      postBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl start vaultwarden.service
      '';
    };

    clan.core.postgresql = {
      databases.${cfg.name} = {
        create = {
          enable = true;
          options = {
            LC_COLLATE = "C";
            LC_CTYPE = "C";
            ENCODING = "UTF8";
            OWNER = cfg.name;
            TEMPLATE = "template0";
          };
        };
        restore.stopOnRestore = ["vaultwarden.service"];
      };
      users.${cfg.name} = {};
    };

    users.users.${cfg.name} = {
      isSystemUser = true;
      description = cfg.name;
      group = lib.mkForce cfg.group;
    };

    clan.core.vars.generators.${cfg.name} = {
      files = {
        pgpassword = {
          owner = cfg.name;
          group = "postgres";
          mode = "0440";
          secret = true;
        };
        admintoken = {
          owner = cfg.name;
          secret = true;
        };
        client_secret = {
          owner = cfg.name;
          secret = true;
        };
        env = {
          owner = cfg.name;
          secret = true;
        };
      };
      runtimeInputs = [pkgs.pwgen];
      script = ''
                mkdir -p "$out"
                pgpassword=$(pwgen -s 64 1)
                admintoken=$(pwgen -s 64 1)
                client_secret=$(pwgen -s 64 1)
                printf '%s
        ' "$pgpassword" > "$out/pgpassword"
                printf '%s
        ' "$admintoken" > "$out/admintoken"
                printf '%s
        ' "$client_secret" > "$out/client_secret"
                {
                  printf 'DATABASE_URL=postgresql://${cfg.name}:%s@127.0.0.1:${toString homelab.postgres.port}/${cfg.name}
        ' "$pgpassword"
                  printf 'ADMIN_TOKEN=%s
        ' "$admintoken"
                  printf 'SSO_CLIENT_SECRET=%s
        ' "$client_secret"
                } > "$out/env"
      '';
    };
  };
}
