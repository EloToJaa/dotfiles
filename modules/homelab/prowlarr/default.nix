{
  variables,
  lib,
  config,
  pkgs,
  ...
}: let
  name = "prowlarr";
  domainName = "prowlarr";
  homelab = variables.homelab;
  group = variables.homelab.groups.main;
  port = 9696;
  dataDir = "${homelab.dataDir}${name}";
in {
  disabledModules = [
    "services/misc/servarr/prowlarr.nix"
  ];

  imports = [
    ./flaresolverr.nix
    ./service.nix
  ];

  services.${name} = {
    enable = true;
    package = pkgs.unstable.prowlarr;
    user = name;
    inherit group dataDir;
  };

  systemd = {
    services.${name}.serviceConfig = {
      UMask = lib.mkForce homelab.defaultUMask;
    };
    tmpfiles.rules = [
      "d ${dataDir} 750 ${name} ${group} - -"
    ];
  };

  services.caddy.virtualHosts."${domainName}.${homelab.baseDomain}" = {
    useACMEHost = homelab.baseDomain;
    extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString port}
    '';
  };

  services.postgresql.ensureUsers = [
    {
      inherit name;
      ensureDBOwnership = false;
    }
  ];
  services.postgresql.ensureDatabases = [
    "${name}-main"
    "${name}-log"
  ];
  services.postgresqlBackup.databases = [
    "${name}-main"
  ];

  users.users.${name} = {
    isSystemUser = true;
    description = name;
    group = lib.mkForce group;
  };

  sops.secrets = {
    "${name}/apikey" = {
      owner = name;
    };
    "${name}/pgpassword" = {
      owner = name;
    };
  };
  sops.templates."config-${name}.xml" = {
    content = ''
      <Config>
        <LogLevel>info</LogLevel>
        <EnableSsl>False</EnableSsl>
        <Port>${toString port}</Port>
        <SslPort>6969</SslPort>
        <UrlBase></UrlBase>
        <BindAddress>*</BindAddress>
        <ApiKey>${config.sops.placeholder."${name}/apikey"}</ApiKey>
        <AuthenticationMethod>Forms</AuthenticationMethod>
        <LaunchBrowser>True</LaunchBrowser>
        <Branch>master</Branch>
        <InstanceName>Prowlarr</InstanceName>
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
    path = "${dataDir}/config.xml";
    owner = name;
  };
}
