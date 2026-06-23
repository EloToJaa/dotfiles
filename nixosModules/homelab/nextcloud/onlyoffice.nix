{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.nextcloud.onlyoffice;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  vars = config.clan.core.vars.generators.${cfg.name};
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
    examplePort = lib.mkOption {
      type = lib.types.port;
      default = 13445;
    };
  };
  disabledModules = [
    "services/web-apps/onlyoffice.nix"
  ];
  imports = [
    ./service.nix
  ];
  config = lib.mkIf cfg.enable {
    services.onlyoffice = {
      inherit (cfg) port examplePort;
      enable = true;
      enableExampleServer = true;
      package = pkgs.unstable.onlyoffice-documentserver;
      hostname = domain;

      postgresHost = "127.0.0.1";
      postgresName = cfg.name;
      postgresUser = cfg.name;
      postgresPasswordFile = vars.files.pgpassword.path;

      jwtSecretFile = vars.files.jwtsecret.path;
      securityNonceFile = vars.files.nonce.path;
    };

    services.nginx.virtualHosts.${domain} = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
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

    clan.core.vars.generators.${cfg.name} = {
      files = {
        pgpassword = {
          owner = cfg.name;
          group = "postgres";
          mode = "0440";
          secret = true;
        };
        jwtsecret = {
          owner = cfg.name;
          secret = true;
        };
        link_secret = {
          owner = cfg.name;
          group = "nginx";
          mode = "0440";
          secret = true;
        };
        nonce = {
          owner = cfg.name;
          group = "nginx";
          mode = "0440";
          secret = true;
        };
      };
      runtimeInputs = [pkgs.pwgen];
      script = ''
                mkdir -p "$out"
                pwgen -s 64 1 > "$out/pgpassword"
                pwgen -s 64 1 > "$out/jwtsecret"
                link_secret=$(pwgen -s 64 1)
                printf '%s
        ' "$link_secret" > "$out/link_secret"
                printf 'set $secure_link_secret "%s";
        ' "$link_secret" > "$out/nonce"
      '';
    };
  };
}
