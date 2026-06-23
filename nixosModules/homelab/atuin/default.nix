{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.atuin;
  vars = config.clan.core.vars.generators.${cfg.name};
in {
  options.modules.homelab.atuin = {
    enable = lib.mkEnableOption "Enable atuin";
    name = lib.mkOption {
      type = lib.types.str;
      default = "atuin";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "atuin";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8888;
    };
  };
  config = lib.mkIf cfg.enable {
    services.atuin = {
      enable = true;
      package = pkgs.atuin;
      openRegistration = false;
      database = {
        uri = null;
        createLocally = false;
      };
    };
    systemd.services.${cfg.name}.serviceConfig = {
      EnvironmentFile = vars.files.env.path;
    };

    services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
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
        restore.stopOnRestore = ["atuin.service"];
      };
      users.${cfg.name} = {};
    };

    clan.core.vars.generators.${cfg.name} = {
      files = {
        pgpassword = {
          owner = cfg.name;
          group = "postgres";
          mode = "0440";
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
                printf '%s
        ' "$pgpassword" > "$out/pgpassword"
                printf 'ATUIN_DB_URI=postgresql://${cfg.name}:%s@127.0.0.1:${toString homelab.postgres.port}/${cfg.name}
        ' "$pgpassword" > "$out/env"
      '';
    };
  };
}
