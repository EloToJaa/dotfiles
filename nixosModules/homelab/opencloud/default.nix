{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.opencloud;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
in {
  options.modules.homelab.opencloud = {
    enable = lib.mkEnableOption "Enable OpenCloud";
    name = lib.mkOption {
      type = lib.types.str;
      default = "opencloud";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "cloud";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.cloud;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 9200;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
  };

  config = lib.mkIf cfg.enable {
    services.opencloud = {
      inherit (cfg) port group;
      enable = true;
      package = pkgs.unstable.opencloud;
      webPackage = pkgs.unstable.opencloud.web;
      idpWebPackage = pkgs.unstable.opencloud.idp-web;
      url = "https://${domain}";
      stateDir = cfg.dataDir;
      user = cfg.name;
      address = "127.0.0.1";
    };
    systemd.services.opencloud.serviceConfig = {
      UMask = lib.mkForce homelab.defaultUMask;
    };
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
    ];

    services.nginx.virtualHosts.${domain} = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };

    clan.core.state.opencloud = {
      folders = [
        cfg.dataDir
      ];
      preBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl stop opencloud.service
      '';

      postBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl start opencloud.service
      '';
    };

    # OpenCloud user is created by services.opencloud
    # We just ensure it's in the right group
    users.users.${cfg.name}.group = lib.mkForce cfg.group;
  };
}
