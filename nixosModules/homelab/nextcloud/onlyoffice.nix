{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.nextcloud.onlyoffice;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
in {
  options.modules.homelab.nextcloud.onlyoffice = {
    enable = lib.mkEnableOption "Enable onlyoffice";
    name = lib.mkOption {
      type = lib.types.str;
      default = "onlyoffice";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "office";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 13444;
    };
  };
  config = lib.mkIf cfg.enable {
    services.onlyoffice = {
      inherit (cfg) port;
      enable = true;
      package = pkgs.unstable.onlyoffice-documentserver;
      hostname = domain;

      postgresHost = "127.0.0.1:${toString homelab.postgres.port}";
      postgresName = cfg.name;
      postgresUser = cfg.name;
      postgresPasswordFile = config.sops.secrets."${cfg.name}/pgpassword".path;

      jwtSecretFile = config.sops.secrets."${cfg.name}/jwtsecret".path;
      securityNonceFile = config.sops.templates."${cfg.name}-nonce.conf".path;
    };

    services.nginx.virtualHosts.${domain} = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations = {
        "/welcome/" = {
          extraConfig = ''
            return 403;
          '';
        };
        "/" = {proxyPass = "http://127.0.0.1:${toString cfg.port}";};
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
        restore.stopOnRestore = [
        ];
      };
      users.${cfg.name} = {};
    };

    sops.secrets = {
      "${cfg.name}/pgpassword" = {
        owner = cfg.name;
      };
      "${cfg.name}/jwtsecret" = {
        owner = cfg.name;
      };
      "${cfg.name}/link_secret" = {
        owner = cfg.name;
      };
    };
    sops.templates."${cfg.name}-nonce.conf" = {
      content = ''
        set $secure_link_secret "${config.sops.placeholder."${cfg.name}/link_secret"}";
      '';
      owner = cfg.name;
    };
  };
}
