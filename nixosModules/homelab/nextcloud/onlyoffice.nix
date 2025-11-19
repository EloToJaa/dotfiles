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

      postgresHost = "127.0.0.1:5432";
      postgresName = cfg.name;
      postgresUser = cfg.name;
      postgresPasswordFile = config.sops.secrets."${cfg.name}/pgpassword".path;

      jwtSecretFile = config.sops.secrets."${cfg.name}/jwtsecret".path;
    };

    services.caddy.virtualHosts.${domain} = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        respond /welcome/* "Access denied" 403 {
          close
        }
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };

    sops.secrets = {
      "${cfg.name}/pgpassword" = {
        owner = cfg.name;
      };
      "${cfg.name}/jwtsecret" = {
        owner = cfg.name;
      };
    };
  };
}
