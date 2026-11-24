{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.vaultwarden;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "vaultwarden";
    port = 8222;
    domainName = "pwd";
    gatus = {
      name = "Vaultwarden";
      group = "apps";
      path = "/alive";
    };
    umaskUnits = ["vaultwarden"];
  };
  domain = "${cfg.domainName}.${homelab.baseDomain}";
in {
  options.modules.homelab.vaultwarden =
    service.options
    // {
      group = lib.mkOption {
        type = lib.types.str;
        default = homelab.groups.main;
      };
    };
  imports = [
    ./auth.nix
  ];
  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
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
      };
      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
      ];

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
          files = {
            pgpassword.deploy = false;
            admintoken.deploy = false;
          };
          runtimeInputs = [
            pkgs.pwgen
            pkgs.libargon2
            pkgs.coreutils
          ];
          script = ''
            pwgen -s 64 1 > "$out/pgpassword"

            admin_password=$(pwgen -s 64 1)
            salt=$(head -c 16 /dev/urandom | base64 -w0 | tr -d '=')
            printf '%s' "$admin_password" \
              | argon2 "$salt" -id -k 19456 -t 2 -p 1 -e \
              | tr -d '\n' > "$out/admintoken"

            printf 'Vaultwarden admin password (shown once, store it in your password manager): %s\n' "$admin_password" >&2
          '';
        };
        "${cfg.name}-env" = {
          dependencies = [cfg.name] ++ lib.optional cfg.auth.enable "${cfg.name}-oidc";
          files.env.owner = cfg.name;
          script = ''
            {
              printf 'DATABASE_URL=postgresql://${cfg.name}:%s@127.0.0.1:${toString homelab.postgres.port}/${cfg.name}\n' "$(cat "$in/${cfg.name}/pgpassword")"
              printf 'ADMIN_TOKEN=%s\n' "$(cat "$in/${cfg.name}/admintoken")"
              ${lib.optionalString cfg.auth.enable ''printf 'SSO_CLIENT_SECRET=%s\n' "$(cat "$in/${cfg.name}-oidc/client-secret")"''}
            } > "$out/env"
          '';
        };
      };
    })
  ];
}
