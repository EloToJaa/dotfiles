{
  config,
  lib,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  inherit (config.settings) timezone;
  cfg = config.modules.homelab.cleanuparr;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "cleanuparr";
    port = 11011;
    gatus = {
      name = "Cleanuparr";
      group = "media";
      path = "/health";
    };
  };
in {
  options.modules.homelab.cleanuparr =
    service.options
    // {
      package = lib.mkPackageOption pkgs "cleanuparr" {};
      id = lib.mkOption {
        type = lib.types.int;
        default = 378;
      };
    };
  imports = [
    ./auth.nix
  ];
  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
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
          WorkingDirectory = "${cfg.package}/lib/cleanuparr";

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

      users.users.${cfg.name} = {
        uid = cfg.id;
        group = cfg.name;
        description = cfg.name;
        home = cfg.dataDir;
        isSystemUser = true;
      };
      users.groups.${cfg.name}.gid = cfg.id;
    })
  ];
}
