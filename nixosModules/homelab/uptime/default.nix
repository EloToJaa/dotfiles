{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.uptime;
in {
  options.modules.homelab.uptime = {
    enable = lib.mkEnableOption "Enable uptime";
    name = lib.mkOption {
      type = lib.types.str;
      default = "uptime";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "uptime";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.main;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3001;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
  };
  config = lib.mkIf cfg.enable {
    services.uptime-kuma = {
      enable = true;
      package = pkgs.unstable.uptime-kuma;
      settings = {
        DATA_DIR = lib.mkForce cfg.dataDir;
        PORT = lib.mkForce (toString cfg.port);
      };
    };
    systemd.services.uptime-kuma.serviceConfig = {
      User = lib.mkForce cfg.name;
      Group = lib.mkForce cfg.group;
      UMask = lib.mkForce homelab.defaultUMask;
      StateDirectory = lib.mkForce null;
      DynamicUser = lib.mkForce false;
      ProtectSystem = lib.mkForce "off";
    };
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
    ];

    services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/".proxyPass = "http://127.0.0.1:${toString cfg.port}";
    };

    clan.core.state.uptime = {
      folders = [
        cfg.dataDir
      ];
      preBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl stop uptime-kuma.service
      '';

      postBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl start uptime-kuma.service
      '';
    };

    users.users.${cfg.name} = {
      isSystemUser = true;
      group = lib.mkForce cfg.group;
    };
  };
}
