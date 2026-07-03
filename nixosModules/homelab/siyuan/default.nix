{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.siyuan;
  accessAuthCode = config.clan.core.vars.generators.siyuan-access-auth-code;
in {
  imports = [
    ./service.nix
  ];

  options.modules.homelab.siyuan = {
    enable = lib.mkEnableOption "Enable SiYuan";

    name = lib.mkOption {
      type = lib.types.str;
      default = "siyuan";
    };

    domainName = lib.mkOption {
      type = lib.types.str;
      default = "notes";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.docs;
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 6806;
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
  };

  config = lib.mkIf cfg.enable {
    services.siyuan = {
      enable = true;
      package = pkgs.unstable.siyuan;
      user = cfg.name;
      inherit (cfg) group port dataDir;
      environmentFile = accessAuthCode.files.env.path;
    };

    clan.core.vars.generators.siyuan-access-auth-code = {
      files.env = {
        owner = cfg.name;
        group = cfg.group;
      };
      runtimeInputs = [pkgs.pwgen];
      script = ''
        mkdir -p "$out"
        printf 'SIYUAN_ACCESS_AUTH_CODE=%s\n' "$(pwgen -s 64 1)" > "$out/env"
      '';
    };

    clan.core.state.siyuan = {
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
      isSystemUser = true;
      description = cfg.name;
      group = cfg.group;
      home = cfg.dataDir;
    };
  };
}
