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
      inherit (cfg) port;
      enable = true;
      package = pkgs.unstable.opencloud;
      webPackage = pkgs.unstable.opencloud.web;
      idpWebPackage = pkgs.unstable.opencloud.idp-web;
      url = "https://${domain}";
      stateDir = cfg.dataDir;
      user = cfg.name;
      group = cfg.name;
      address = "127.0.0.1";
      environmentFile = config.clan.core.vars.generators.opencloud.files."envfile".path;
      environment = {
        OC_INSECURE = "true";
        INITIAL_ADMIN_PASSWORD = "Test1234";
        COLLABORA_DOMAIN = "https://docs.${homelab.baseDomain}";
        WOPISERVER_DOMAIN = "https://wopiserver.${homelab.baseDomain}";
      };
      settings = {
        opencloud = {
          proxy.insecure_backends = true;
        };
      };
    };

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

    clan.core.vars.generators.opencloud = {
      files.envfile = {
        owner = "opencloud";
        group = "opencloud";
      };
      runtimeInputs = with pkgs; [
        util-linux
        pwgen
      ];
      script = ''
        mkdir -p $out

        # Generate required secrets (matching opencloud init output)
        SERVICE_ACCOUNT_ID=$(uuidgen)
        STORAGE_UUID=$(uuidgen)

        {
          echo "OC_JWT_SECRET=$(pwgen -s 64 1)"
          echo "OC_TRANSFER_SECRET=$(pwgen -s 64 1)"
          echo "OC_MACHINE_AUTH_API_KEY=$(pwgen 64 1)"
          echo "OC_SYSTEM_USER_ID=$(uuidgen)"
          echo "OC_SYSTEM_USER_API_KEY=$(pwgen -s 64 1)"
          echo "OC_ADMIN_USER_ID=$(uuidgen)"
          echo "GRAPH_APPLICATION_ID=$(uuidgen)"
          echo "OC_SERVICE_ACCOUNT_ID=$SERVICE_ACCOUNT_ID"
          echo "OC_SERVICE_ACCOUNT_SECRET=$(pwgen -s 64 1)"
          echo "STORAGE_USERS_MOUNT_ID=$STORAGE_UUID"
          echo "GATEWAY_STORAGE_USERS_MOUNT_ID=$STORAGE_UUID"
          echo "THUMBNAILS_TRANSFER_SECRET=$(pwgen -s 64 1)"
          echo "OC_URL_SIGNING_SECRET=$(pwgen -s 64 1)"
        } > $out/envfile
      '';
    };
  };
}
