{
  config,
  lib,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  inherit (config.settings) timezone;
  cfg = config.modules.homelab.yamtrack;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "yamtrack";
    port = 3008;
    description = "Enable Yamtrack";
    domainName = "track";
    glance.icon = "di:yamtrack";
    gatus = {
      name = "Yamtrack";
      group = "media";
      conditions = ["[STATUS] < 400"];
    };
  };
  secret = config.clan.core.vars.generators.yamtrack-secret;
  redisServer = config.services.redis.servers.yamtrack;
  serviceNames = ["yamtrack" "yamtrack-worker" "yamtrack-beat"];
in {
  imports = [
    ./auth.nix
    ./service.nix
  ];

  options.modules.homelab.yamtrack =
    service.options;

  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
      services.yamtrack = {
        enable = true;
        package = pkgs.yamtrack;
        user = cfg.name;
        group = cfg.name;
        inherit (cfg) dataDir port;
        environmentFile = secret.files.env.path;
        databaseHost = "127.0.0.1";
        databaseName = cfg.name;
        databaseUser = cfg.name;
        databasePort = homelab.postgres.port;
        redisSocket = redisServer.unixSocket;
        inherit timezone;
        url = "https://${cfg.domainName}.${homelab.baseDomain}";
      };

      services.redis.servers.yamtrack.enable = true;

      systemd.services =
        lib.genAttrs serviceNames (_: {
          serviceConfig.SupplementaryGroups = [redisServer.group];
        })
        // {
          yamtrack-migrate = {
            after = ["postgresql.service" "redis-yamtrack.service"];
            requires = ["postgresql.service" "redis-yamtrack.service"];
            serviceConfig.SupplementaryGroups = [redisServer.group];
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
          restore.stopOnRestore = map (name: "${name}.service") serviceNames;
        };
        users.${cfg.name} = {};
      };

      services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}".locations."/static/".alias = "${pkgs.yamtrack}/share/yamtrack/staticfiles/";

      clan.core.vars.generators.yamtrack-secret = {
        files.env = {
          owner = cfg.name;
          group = cfg.name;
        };
        runtimeInputs = [pkgs.pwgen];
        script = ''
          mkdir -p "$out"
          printf 'SECRET=%s\nDB_PASSWORD=%s\n' \
            "$(pwgen -s 64 1)" \
            "$(pwgen -s 64 1)" \
            > "$out/env"
        '';
      };

      clan.core.state.yamtrack = {
        folders = [cfg.dataDir];
        preBackupScript = ''
          export PATH=${lib.makeBinPath [config.systemd.package]}

          systemctl stop ${lib.concatMapStringsSep " " (name: "${name}.service") serviceNames}
        '';
        postBackupScript = ''
          export PATH=${lib.makeBinPath [config.systemd.package]}

          systemctl start ${lib.concatMapStringsSep " " (name: "${name}.service") serviceNames}
        '';
      };
    })
  ];
}
