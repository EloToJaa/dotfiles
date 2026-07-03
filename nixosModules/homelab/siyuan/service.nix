{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.siyuan;
in {
  options.services.siyuan = {
    enable = lib.mkEnableOption "SiYuan, a privacy-first personal knowledge management system";

    package = lib.mkPackageOption pkgs "siyuan" {};

    user = lib.mkOption {
      type = lib.types.str;
      default = "siyuan";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "siyuan";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 6806;
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/siyuan";
      description = "SiYuan workspace directory.";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Environment file for secrets. Use it to set SIYUAN_ACCESS_AUTH_CODE.
      '';
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open port in the firewall for the SiYuan web interface.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.siyuan = {
      description = "SiYuan note-taking workspace";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig =
        {
          User = cfg.user;
          Group = cfg.group;
          ExecStart = "${lib.getExe' cfg.package.kernel "kernel"} --workspace=${cfg.dataDir} --port=${toString cfg.port}";
          WorkingDirectory = "${cfg.package}/share/siyuan/resources";
          Restart = "on-failure";
          RestartSec = 5;

          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectHome = true;
          ProtectSystem = "strict";
          ReadWritePaths = [cfg.dataDir];
          UMask = "0077";
        }
        // lib.optionalAttrs (cfg.environmentFile != null) {
          EnvironmentFile = cfg.environmentFile;
        };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 750 ${cfg.user} ${cfg.group} - -"
    ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [cfg.port];
    };
  };
}
