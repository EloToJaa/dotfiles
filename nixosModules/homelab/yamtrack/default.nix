{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  inherit (config.settings) timezone;
  cfg = config.modules.homelab.yamtrack;
  secret = config.clan.core.vars.generators.yamtrack-secret;
  redisServer = config.services.redis.servers.yamtrack;
  serviceNames = ["yamtrack" "yamtrack-worker" "yamtrack-beat"];
in {
  imports = [./service.nix];

  options.modules.homelab.yamtrack = {
    enable = lib.mkEnableOption "Enable Yamtrack";

    name = lib.mkOption {
      type = lib.types.str;
      default = "yamtrack";
    };

    domainName = lib.mkOption {
      type = lib.types.str;
      default = "yamtrack";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8000;
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };

    id = lib.mkOption {
      type = lib.types.int;
      default = 380;
    };
  };

  config = lib.mkIf cfg.enable {
    services.yamtrack = {
      enable = true;
      package = pkgs.yamtrack;
      user = cfg.name;
      group = cfg.name;
      inherit (cfg) dataDir port;
      environmentFile = secret.files.env.path;
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
          after = ["redis-yamtrack.service"];
          requires = ["redis-yamtrack.service"];
          serviceConfig.SupplementaryGroups = [redisServer.group];
        };
      };

    services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
        "/static/".alias = "${pkgs.yamtrack}/share/yamtrack/staticfiles/";
      };
    };

    clan.core.vars.generators.yamtrack-secret = {
      files.env = {
        owner = cfg.name;
        group = cfg.name;
      };
      runtimeInputs = [pkgs.pwgen];
      script = ''
        mkdir -p "$out"
        printf 'SECRET=%s\n' "$(pwgen -s 64 1)" > "$out/env"
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
    users.users.${cfg.name} = {
      uid = cfg.id;
    };
    users.groups.${cfg.name}.gid = cfg.id;
  };
}
