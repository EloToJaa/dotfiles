{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.sonarr;
  vars = config.clan.core.vars.generators.${cfg.name};
in {
  options.modules.homelab.sonarr = {
    enable = lib.mkEnableOption "Enable sonarr";
    name = lib.mkOption {
      type = lib.types.str;
      default = "sonarr";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "sonarr";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.media;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8989;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
  };
  config = lib.mkIf cfg.enable {
    services.sonarr = {
      enable = true;
      package = pkgs.unstable.sonarr;
      user = cfg.name;
      inherit (cfg) group dataDir;
    };
    systemd.services.${cfg.name} = {
      preStart = lib.mkBefore ''
        ${pkgs.coreutils}/bin/install -m 0600 ${vars.files.config.path} ${cfg.dataDir}/config.xml
      '';
      serviceConfig.UMask = lib.mkForce homelab.defaultUMask;
    };
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
    ];

    services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };

    clan.core.postgresql = {
      databases = {
        "${cfg.name}-main" = {
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
          restore.stopOnRestore = ["sonarr.service"];
        };
        "${cfg.name}-log" = {
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
          restore.stopOnRestore = ["sonarr.service"];
        };
      };
      users.${cfg.name} = {};
    };

    users.users.${cfg.name} = {
      isSystemUser = true;
      description = cfg.name;
      inherit (cfg) group;
    };

    clan.core.vars.generators.${cfg.name} = {
      files = {
        apikey = {
          owner = cfg.name;
          secret = true;
        };
        pgpassword = {
          owner = cfg.name;
          group = "postgres";
          mode = "0440";
          secret = true;
        };
        config = {
          owner = cfg.name;
          secret = true;
        };
      };
      runtimeInputs = [pkgs.pwgen];
      script = ''
                mkdir -p "$out"
                apikey=$(pwgen -s 64 1)
                pgpassword=$(pwgen -s 64 1)
                printf '%s\n' "$apikey" > "$out/apikey"
                printf '%s\n' "$pgpassword" > "$out/pgpassword"
                cat > "$out/config" <<EOF
        <Config>
          <LogLevel>info</LogLevel>
          <EnableSsl>False</EnableSsl>
          <Port>${toString cfg.port}</Port>
          <SslPort>9898</SslPort>
          <UrlBase></UrlBase>
          <BindAddress>127.0.0.1</BindAddress>
          <ApiKey>$apikey</ApiKey>
          <AuthenticationMethod>Forms</AuthenticationMethod>
          <LaunchBrowser>True</LaunchBrowser>
          <Branch>main</Branch>
          <InstanceName>Sonarr</InstanceName>
          <AuthenticationRequired>Enabled</AuthenticationRequired>
          <SslCertPath></SslCertPath>
          <SslCertPassword></SslCertPassword>
          <PostgresUser>${cfg.name}</PostgresUser>
          <PostgresPassword>$pgpassword</PostgresPassword>
          <PostgresPort>${toString homelab.postgres.port}</PostgresPort>
          <PostgresHost>127.0.0.1</PostgresHost>
          <AnalyticsEnabled>False</AnalyticsEnabled>
          <Theme>auto</Theme>
        </Config>
        EOF
      '';
    };
  };
}
