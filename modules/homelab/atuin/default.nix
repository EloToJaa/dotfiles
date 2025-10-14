{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.modules.homelab) homelab;
  cfg = config.modules.homelab.atuin;
in {
  options.modules.homelab.atuin = {
    enable = lib.mkEnableOption "Atuin module";
    name = lib.mkOption {
      type = lib.types.str;
      default = "atuin";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "atuin";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8888;
    };
  };
  services.atuin = {
    enable = true;
    package = pkgs.unstable.atuin;
    openRegistration = false;
    database = {
      uri = null;
      createLocally = false;
    };
  };
  systemd.services.${cfg.name}.serviceConfig = {
    EnvironmentFile = config.sops.templates."${cfg.name}.env".path;
  };

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
    cfg.name
  ];
  services.postgresqlBackup.databases = [
    cfg.name
  ];

  sops.secrets = {
    "${cfg.name}/pgpassword" = {};
  };
  sops.templates."${cfg.name}.env".content = ''
    ATUIN_DB_URI=postgresql://${cfg.name}:${config.sops.placeholder."${cfg.name}/pgpassword"}@127.0.0.1:5432/${cfg.name}
  '';
}
