{
  variables,
  config,
  ...
}: let
  name = "pgadmin";
  domainName = "pgadmin";
  homelab = variables.homelab;
  port = 5050;
in {
  services.${name} = {
    enable = true;
    port = port;
    initialEmail = variables.email;
    initialPasswordFile = config.sops.secrets."pgadmin/password".path;
  };
  systemd.services.${name}.serviceConfig = {
    EnvironmentFile = config.sops.templates."${name}.env".path;
  };

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
    name
  ];

  sops.secrets = {
    "${name}/password" = {
      owner = name;
    };
    "${name}/pgpassword" = {
      owner = name;
    };
  };
  sops.templates."${name}.env".content = ''
    CONFIG_DATABASE_URI=postgresql://${name}:${config.sops.placeholder."${name}/pgpassword"}@127.0.0.1:5432/${name}
  '';
}
