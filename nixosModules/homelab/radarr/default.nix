{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.radarr;
in {
  options.modules.homelab.radarr = {
    enable = lib.mkEnableOption "Enable radarr";
    name = lib.mkOption {
      type = lib.types.str;
      default = "radarr";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "radarr";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.media;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 7878;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.dataDir}${cfg.name}";
    };
  };
  config = lib.mkIf cfg.enable {
    services.radarr = {
      enable = true;
      package = pkgs.unstable.radarr;
      user = cfg.name;
      inherit (cfg) group dataDir;
    };
    systemd.services.radarr.serviceConfig.UMask = lib.mkForce homelab.defaultUMask;
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
    ];

    services.caddy.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };

    services.postgresql.ensureUsers = [
      {
        inherit (cfg) name;
        ensureDBOwnership = false;
      }
    ];
    services.postgresql.ensureDatabases = [
      "${cfg.name}-main"
      "${cfg.name}-log"
    ];
    services.postgresqlBackup.databases = [
      "${cfg.name}-main"
    ];

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
          <SslPort>8787</SslPort>
          <UrlBase></UrlBase>
          <BindAddress>127.0.0.1</BindAddress>
          <ApiKey>${config.sops.placeholder."${cfg.name}/apikey"}</ApiKey>
          <AuthenticationMethod>Forms</AuthenticationMethod>
          <LaunchBrowser>True</LaunchBrowser>
          <Branch>master</Branch>
          <InstanceName>Radarr</InstanceName>
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
