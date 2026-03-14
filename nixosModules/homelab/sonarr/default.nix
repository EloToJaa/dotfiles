{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.sonarr;
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
      default = "${homelab.dataDir}${cfg.name}";
    };
  };
  config = lib.mkIf cfg.enable {
    services.sonarr = {
      enable = true;
      package = pkgs.unstable.sonarr;
      user = cfg.name;
      inherit (cfg) group dataDir;
    };
    systemd.services.sonarr.serviceConfig.UMask = lib.mkForce homelab.defaultUMask;
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
    ];

    services.caddy.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
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

    sops.secrets = {
      "${cfg.name}/apikey" = {
        owner = cfg.name;
      };
      "${cfg.name}/pgpassword" = {
        owner = cfg.name;
      };
    };
    sops.templates."config-${cfg.name}.xml" = {
      content = ''
        <Config>
          <LogLevel>info</LogLevel>
          <EnableSsl>False</EnableSsl>
          <Port>${toString cfg.port}</Port>
          <SslPort>9898</SslPort>
          <UrlBase></UrlBase>
          <BindAddress>127.0.0.1</BindAddress>
          <ApiKey>${config.sops.placeholder."${cfg.name}/apikey"}</ApiKey>
          <AuthenticationMethod>Forms</AuthenticationMethod>
          <LaunchBrowser>True</LaunchBrowser>
          <Branch>main</Branch>
          <InstanceName>Sonarr</InstanceName>
          <AuthenticationRequired>Enabled</AuthenticationRequired>
          <SslCertPath></SslCertPath>
          <SslCertPassword></SslCertPassword>
          <PostgresUser>${cfg.name}</PostgresUser>
          <PostgresPassword>${config.sops.placeholder."${cfg.name}/pgpassword"}</PostgresPassword>
          <PostgresPort>${toString homelab.postgres.port}</PostgresPort>
          <PostgresHost>127.0.0.1</PostgresHost>
          <AnalyticsEnabled>False</AnalyticsEnabled>
          <Theme>auto</Theme>
        </Config>
      '';
      path = "${cfg.dataDir}/config.xml";
      owner = cfg.name;
    };
  };
}
