{
  pkgs,
  config,
  lib,
  ...
}: let
  homelab = config.modules.homelab;
  cfg = homelab.postgres;
  setRolePassword = name: generator: ''
    $PSQL -v ON_ERROR_STOP=1 <<'SQL'
    \set role ${name}
    \set password `cat ${config.clan.core.vars.generators.${generator}.files.pgpassword.path}`
    SELECT format('ALTER ROLE %I WITH PASSWORD %L', :'role', :'password') \gexec
    SQL
  '';
  servicePassword = module:
    lib.optionals module.enable [
      (setRolePassword module.name module.name)
    ];
in {
  options.modules.homelab.postgres = {
    enable = lib.mkEnableOption "Enable postgres";
    port = lib.mkOption {
      type = lib.types.port;
      default = 5432;
    };
  };
  imports = [
    ./pgadmin.nix
  ];
  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      package = pkgs.unstable.postgresql_18;
      settings.port = cfg.port;
      enableTCPIP = true;
    };

    systemd.services.postgresql.postStart = lib.mkAfter (lib.concatStringsSep "\n" (
      servicePassword homelab.atuin
      ++ servicePassword homelab.authelia
      ++ servicePassword homelab.lldap
      ++ servicePassword homelab.bazarr
      ++ servicePassword homelab.jellystat
      ++ servicePassword homelab.n8n
      ++ servicePassword homelab.nextcloud
      ++ servicePassword homelab.nextcloud.onlyoffice
      ++ servicePassword homelab.paperless
      ++ servicePassword homelab.postgres.pgadmin
      ++ servicePassword homelab.prowlarr
      ++ servicePassword homelab.radarr
      ++ servicePassword homelab.seerr
      ++ servicePassword homelab.sonarr
      ++ servicePassword homelab.vaultwarden
    ));

    clan.core.postgresql.enable = true;

    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
