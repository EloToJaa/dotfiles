{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.forgejo;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
in {
  options.modules.homelab.forgejo = {
    enable = lib.mkEnableOption "Enable forgejo";
    name = lib.mkOption {
      type = lib.types.str;
      default = "forgejo";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "git";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
    };
  };

  config = lib.mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      package = pkgs.forgejo;
      user = cfg.name;
      group = cfg.name;
      stateDir = cfg.dataDir;
      database.type = "sqlite3";
      lfs.enable = true;
      settings = {
        server = {
          DOMAIN = domain;
          ROOT_URL = "https://${domain}/";
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = cfg.port;
          SSH_DOMAIN = domain;
        };
        service.DISABLE_REGISTRATION = true;
        session.COOKIE_SECURE = true;
      };
    };
    systemd.services.forgejo.serviceConfig.UMask = lib.mkForce homelab.defaultUMask;

    services.nginx.virtualHosts.${domain} = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 512M;
        '';
      };
    };

    clan.core.state.forgejo = {
      folders = [cfg.dataDir];
      preBackupScript = ''
        export PATH=${lib.makeBinPath [config.systemd.package]}
        systemctl stop forgejo.service
      '';
      postBackupScript = ''
        export PATH=${lib.makeBinPath [config.systemd.package]}
        systemctl start forgejo.service
      '';
    };
  };
}
