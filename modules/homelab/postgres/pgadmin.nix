{
  variables,
  config,
  pkgs,
  ...
}: let
  inherit (variables) homelab;
  name = "pgadmin";
  domainName = "pgadmin";
  port = 5050;
in {
  services.${name} = {
    enable = true;
    package = pkgs.unstable.pgadmin4;
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
      inherit name;
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
