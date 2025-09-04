{
  variables,
  pkgs,
  config,
  ...
}: let
  inherit (variables) homelab;
  name = "atuin";
  domainName = "atuin";
  port = 8888;
in {
  services.${name} = {
    enable = true;
    package = pkgs.unstable.atuin;
    openRegistration = false;
    database = {
      uri = null;
      createLocally = false;
    };
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
  services.postgresqlBackup.databases = [
    name
  ];

  sops.secrets = {
    "${name}/pgpassword" = {};
  };
  sops.templates."${name}.env".content = ''
    ATUIN_DB_URI=postgresql://${name}:${config.sops.placeholder."${name}/pgpassword"}@127.0.0.1:5432/${name}
  '';
}
