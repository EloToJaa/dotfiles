{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.opencloud;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  oidcIssuer = "https://auth.${homelab.baseDomain}";
  oidcClientId = "web";
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
        # OC_LOG_LEVEL = "warn";

        # Disable TLS on proxy - Caddy handles TLS termination
        PROXY_TLS = "false";

        # Disable built-in IDP since we use external OIDC (Authelia)
        OC_EXCLUDE_RUN_SERVICES = "idp";

        # External OIDC configuration
        OC_OIDC_ISSUER = oidcIssuer;
        PROXY_OIDC_ISSUER = oidcIssuer;
        PROXY_OIDC_REWRITE_WELLKNOWN = "false";
        PROXY_OIDC_ACCESS_TOKEN_VERIFY_METHOD = "none";
        PROXY_OIDC_SKIP_USER_INFO = "false";

        # OIDC client ID for web
        WEB_OIDC_CLIENT_ID = oidcClientId;

        # Auto-provision accounts from OIDC
        PROXY_AUTOPROVISION_ACCOUNTS = "true";
        PROXY_AUTOPROVISION_CLAIM_USERNAME = "preferred_username";
        PROXY_AUTOPROVISION_CLAIM_EMAIL = "email";
        PROXY_AUTOPROVISION_CLAIM_DISPLAYNAME = "name";
        PROXY_AUTOPROVISION_CLAIM_GROUPS = "groups";
        PROXY_USER_OIDC_CLAIM = "preferred_username";
        PROXY_USER_CS3_CLAIM = "username";
        GRAPH_USERNAME_MATCH = "none";

        # Avoid port conflicts with prometheus exporters (9115 = blackbox_exporter)
        WEB_HTTP_ADDR = "127.0.0.1:9105";
        WEBDAV_HTTP_ADDR = "127.0.0.1:9116";
        COLLABORATION_HTTP_ADDR = "127.0.0.1:9300";
        COLLABORATION_GRPC_ADDR = "127.0.0.1:9301";
      };
      # OpenCloud configuration (prevents init service from running)
      settings = {
        # Main opencloud config - non-empty value prevents opencloud init from running
        opencloud = {
          graph.spaces.insecure = true;
          proxy.insecure_backends = true;
        };
        # Proxy config
        proxy.csp_config_file_location = "/etc/opencloud/csp.yaml";
        # CSP - allow connecting to external OIDC provider
        csp.directives = {
          "connect-src" = ["https://${domain}/" oidcIssuer];
          "frame-src" = ["https://${domain}/" oidcIssuer];
          "script-src" = ["'self'" "'unsafe-inline'" "'unsafe-eval'"];
        };
        # Web UI OIDC configuration
        web.web.config = {
          server = "https://${domain}";
          oidc = {
            metadata_url = "${oidcIssuer}/.well-known/openid-configuration";
            authority = oidcIssuer;
            client_id = oidcClientId;
            response_type = "code";
            scope = "openid offline_access profile email groups";
          };
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
        owner = cfg.name;
        group = cfg.name;
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

        REVA_PASSWORD=$(pwgen -s 64 1)
        IDM_PASSWORD=$(pwgen -s 64 1)
        IDP_PASSWORD=$(pwgen -s 64 1)
        ADMIN_PASSWORD=$(pwgen -s 64 1)

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
          echo "COLLABORATION_WOPI_SECRET=$(pwgen -s 64 1)"
          echo "OC_URL_SIGNING_SECRET=$(pwgen -s 64 1)"

          # LDAP bind passwords for internal services
          echo "IDM_ADMIN_PASSWORD=$ADMIN_PASSWORD"
          echo "IDM_SVC_PASSWORD=$IDM_PASSWORD"
          echo "IDM_REVASVC_PASSWORD=$REVA_PASSWORD"
          echo "IDM_IDPSVC_PASSWORD=$IDP_PASSWORD"
          echo "GRAPH_LDAP_BIND_PASSWORD=$IDM_PASSWORD"
          echo "OC_LDAP_BIND_PASSWORD=$REVA_PASSWORD"
          echo "LDAP_BIND_PASSWORD=$REVA_PASSWORD"
          echo "AUTH_BASIC_LDAP_BIND_PASSWORD=$REVA_PASSWORD"
          echo "GROUPS_LDAP_BIND_PASSWORD=$REVA_PASSWORD"
          echo "USERS_LDAP_BIND_PASSWORD=$REVA_PASSWORD"
          echo "IDP_LDAP_BIND_PASSWORD=$IDP_PASSWORD"
        } > $out/envfile
      '';
    };
  };
}
