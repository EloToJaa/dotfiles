{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.vaultwarden;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
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
      environmentFile = config.clan.core.vars.generators."${cfg.name}-env".files.env.path;
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

    clan.core.vars.generators = {
      ${cfg.name} = {
        prompts.client_secret = {
          description = "Vaultwarden OIDC client secret (must match the authelia client)";
          type = "hidden";
          persist = true;
        };
        files = {
          pgpassword.deploy = false;
          admintoken.deploy = false;
          client_secret.deploy = false;
        };
        runtimeInputs = [pkgs.pwgen];
        script = ''
          pwgen -s 64 1 > "$out/pgpassword"
          pwgen -s 64 1 > "$out/admintoken"
        '';
      };
      "${cfg.name}-env" = {
        dependencies = [cfg.name];
        files.env.owner = cfg.name;
        script = ''
          {
            printf 'DATABASE_URL=postgresql://${cfg.name}:%s@127.0.0.1:${toString homelab.postgres.port}/${cfg.name}\n' "$(cat "$in/${cfg.name}/pgpassword")"
            printf 'ADMIN_TOKEN=%s\n' "$(cat "$in/${cfg.name}/admintoken")"
            printf 'SSO_CLIENT_SECRET=%s\n' "$(cat "$in/${cfg.name}/client_secret")"
          } > "$out/env"
        '';
      };
    };
  };
}
