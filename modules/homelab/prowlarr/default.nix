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
in {
  services.${name} = {
    enable = true;
  };
  systemd.services.${name}.serviceConfig = {
    User = name;
    Group = group;
    StateDirectory = lib.mkForce null;
    DynamicUser = lib.mkForce false;
    UMask = lib.mkForce homelab.defaultUMask;
    ExecStart = lib.mkForce ''"${pkgs.prowlarr}/bin/Prowlarr" "-nobrowser" "-data=${homelab.dataDir}${name}"'';
  };
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
    description = "${name}";
    group = "${group}";
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
      path = "${homelab.dataDir}${name}/config.xml";
      owner = name;
    };
  };

  imports = [./flaresolverr.nix];
}
