{
  variables,
  lib,
  config,
  ...
}: let
  name = "sonarr";
  domainName = "sonarr";
  homelab = variables.homelab;
  group = variables.homelab.groups.media;
  port = 8989;
in {
  services.${name} = {
    enable = true;
    user = "${name}";
    group = "${group}";
    dataDir = "${homelab.dataDir}${name}";
  };
  systemd.services.${name}.serviceConfig.UMask = lib.mkForce homelab.defaultUMask;
  systemd.tmpfiles.rules = [
    "d ${homelab.dataDir}${name} 750 ${name} ${group} - -"
  ];

  services.caddy.virtualHosts."${domainName}.${homelab.baseDomain}" = {
    useACMEHost = homelab.baseDomain;
    extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString port}
    '';
  };

  services.postgresql.ensureUsers = [
    {
      name = name;
      ensureDBOwnership = false;
    }
  ];
  services.postgresql.ensureDatabases = [
    "${name}-main"
    "${name}-log"
  ];

  users.users.${name} = {
    isSystemUser = true;
    description = name;
    group = group;
  };

  sops.secrets = {
    "${name}/apikey" = {
      owner = name;
    };
    "${name}/pgpassword" = {
      owner = name;
    };
  };
  sops.templates = {
    "config-${name}.xml" = {
      content = ''
        <Config>
          <LogLevel>info</LogLevel>
          <EnableSsl>False</EnableSsl>
          <Port>${toString port}</Port>
          <SslPort>9898</SslPort>
          <UrlBase></UrlBase>
          <BindAddress>*</BindAddress>
          <ApiKey>${config.sops.placeholder."${name}/apikey"}</ApiKey>
          <AuthenticationMethod>Forms</AuthenticationMethod>
          <LaunchBrowser>True</LaunchBrowser>
          <Branch>main</Branch>
          <InstanceName>Sonarr</InstanceName>
          <AuthenticationRequired>Enabled</AuthenticationRequired>
          <SslCertPath></SslCertPath>
          <SslCertPassword></SslCertPassword>
          <PostgresUser>${name}</PostgresUser>
          <PostgresPassword>${config.sops.placeholder."${name}/pgpassword"}</PostgresPassword>
          <PostgresPort>5432</PostgresPort>
          <PostgresHost>127.0.0.1</PostgresHost>
          <AnalyticsEnabled>False</AnalyticsEnabled>
          <Theme>auto</Theme>
        </Config>
      '';
      path = "${homelab.dataDir}${name}/config.xml";
      owner = name;
    };
  };
}
