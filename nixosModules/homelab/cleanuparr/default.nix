{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  inherit (config.settings) timezone;
  cfg = config.modules.homelab.cleanuparr;
in {
  options.modules.homelab.cleanuparr = {
    enable = lib.mkEnableOption "Enable cleanuparr";
    name = lib.mkOption {
      type = lib.types.str;
      default = "cleanuparr";
    };
    package = lib.mkPackageOption pkgs "cleanuparr" {};
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "cleanuparr";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 11011;
    };
    id = lib.mkOption {
      type = lib.types.int;
      default = 378;
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.${cfg.name} = {
      description = "Cleanuparr";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      environment = {
        BIND_ADDRESS = "127.0.0.1";
        DOTNET_RUNNING_IN_CONTAINER = "true";
        PGID = toString cfg.id;
        PORT = toString cfg.port;
        PUID = toString cfg.id;
        TZ = timezone;
        UMASK = homelab.defaultUMask;
      };

      serviceConfig = {
        User = cfg.name;
        Group = cfg.name;
        ExecStart = lib.getExe cfg.package;
        Restart = "on-failure";
        RestartSec = 5;
        UMask = homelab.defaultUMask;
        BindPaths = ["${cfg.dataDir}:/config"];
        WorkingDirectory = cfg.dataDir;

        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadWritePaths = [
          cfg.dataDir
          "/config"
        ];
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 770 ${cfg.name} ${cfg.name} - -"
      # Cleanuparr hard-codes /config when DOTNET_RUNNING_IN_CONTAINER=true.
      "d /config 000 root root - -"
    ];

    clan.core.state.cleanuparr = {
      folders = [
        cfg.dataDir
      ];
      preBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl stop ${cfg.name}.service
      '';

      postBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl start ${cfg.name}.service
      '';
    };

    services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };

    users.users.${cfg.name} = {
      uid = cfg.id;
      group = cfg.name;
      description = cfg.name;
      home = cfg.dataDir;
      isSystemUser = true;
    };
    users.groups.${cfg.name}.gid = cfg.id;
  };
}
