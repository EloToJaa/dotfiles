{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.vaultwarden;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
in {
  options.modules.homelab.vaultwarden = {
    enable = lib.mkEnableOption "Enable vaultwarden";
    name = lib.mkOption {
      type = lib.types.str;
      default = "vaultwarden";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "pwd";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.main;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8222;
    };
  };
  config = lib.mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      package = pkgs.unstable.vaultwarden;
      dbBackend = "postgresql";
      environmentFile = config.sops.templates."${cfg.name}.env".path;
      config = {
        domain = "https://${domain}";
        rocketPort = cfg.port;
        signupsAllowed = false;
        invitationsAllowed = false;
        websocketEnabled = true;
      };
    };
    systemd.services.vaultwarden.serviceConfig = {
      Group = lib.mkForce cfg.group;
      UMask = lib.mkForce homelab.defaultUMask;
    };
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
    ];

    services.caddy.virtualHosts.${domain} = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };

    clan.core.state.vaultwarden = {
      folders = [
        cfg.dataDir
      ];
      preBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl stop vaultwarden.service
      '';

      postBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl start vaultwarden.service
      '';
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
        restore.stopOnRestore = ["vaultwarden.service"];
      };
      users.${cfg.name} = {};
    };

    users.users.${cfg.name} = {
      isSystemUser = true;
      description = cfg.name;
      group = lib.mkForce cfg.group;
    };

    sops.secrets = {
      "${cfg.name}/pgpassword" = {
        owner = cfg.name;
      };
      "${cfg.name}/admintoken" = {
        owner = cfg.name;
      };
    };
    sops.templates."${cfg.name}.env" = {
      content = ''
        DATABASE_URL=postgresql://${cfg.name}:${config.sops.placeholder."${cfg.name}/pgpassword"}@127.0.0.1:${toString homelab.postgres.port}/${cfg.name}
        ADMIN_TOKEN=${config.sops.placeholder."${cfg.name}/admintoken"}
      '';
      owner = cfg.name;
    };
  };
}
