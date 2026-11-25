{
  config,
  lib,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.qui;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "qui";
    port = 7476;
    description = "Enable qui, a qBittorrent web UI";
    domainName = "download";
    dataDir = false;
    glance.icon = "di:qui";
    gatus = {
      name = "qui";
      group = "media";
      path = "/health";
    };
  };
in {
  imports = [./auth.nix];

  options.modules.homelab.qui = service.options;
  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
      services.qui = {
        enable = true;
        package = pkgs.unstable.qui;
        secretFile = config.clan.core.vars.generators.${cfg.name}.files.session-secret.path;
        settings = {
          host = "127.0.0.1";
          inherit (cfg) port;
          databaseEngine = "postgres";
        };
      };

      systemd.services.qui = {
        after = ["postgresql.service"];
        requires = ["postgresql.service"];
        serviceConfig = {
          LoadCredential = lib.mkForce [
            "sessionSecret:${config.clan.core.vars.generators.${cfg.name}.files.session-secret.path}"
            "databaseDsn:${config.clan.core.vars.generators."${cfg.name}-dsn".files.dsn.path}"
          ];
          Environment = ["QUI__DATABASE_DSN_FILE=%d/databaseDsn"];
        };
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
          restore.stopOnRestore = ["qui.service"];
        };
        users.${cfg.name} = {};
      };

      clan.core.vars.generators.${cfg.name} = {
        files = {
          session-secret = {};
          pgpassword.deploy = false;
        };
        runtimeInputs = with pkgs; [
          openssl
          pwgen
        ];
        script = ''
          openssl rand -hex 32 | tr -d '\n' > $out/session-secret
          pwgen -s 64 1 | tr -d '\n' > $out/pgpassword
        '';
      };

      clan.core.vars.generators."${cfg.name}-dsn" = {
        dependencies = [cfg.name];
        files.dsn = {};
        script = ''
          printf 'postgres://${cfg.name}:%s@127.0.0.1:${toString homelab.postgres.port}/${cfg.name}?sslmode=disable' \
            "$(cat "$in/${cfg.name}/pgpassword")" \
            > "$out/dsn"
        '';
      };

      clan.core.state.${cfg.name} = {
        folders = ["/var/lib/qui"];
        preBackupScript = ''
          export PATH=${lib.makeBinPath [config.systemd.package]}

          systemctl stop qui.service
        '';
        postBackupScript = ''
          export PATH=${lib.makeBinPath [config.systemd.package]}

          systemctl start qui.service
        '';
      };
    })
  ];
}
