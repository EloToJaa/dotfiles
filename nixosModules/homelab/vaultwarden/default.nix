{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.vaultwarden;
in {
  options.modules.homelab.vaultwarden = {
    enable = lib.mkEnableOption "Enable vaultwarden";
    name = lib.mkOption {
      type = lib.types.str;
      default = "vaultwarden";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "pwd";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.main;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8222;
    };
  };
  config = lib.mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      package = pkgs.unstable.vaultwarden;
      dbBackend = "postgresql";
      environmentFile = config.clan.core.generators.vaultwarden.files.envfile.path;
      config = {
        domain = "${cfg.domainName}.${homelab.baseDomain}";
        rocketPort = cfg.port;
        signupsAllowed = false;
        invitationsAllowed = false;
        websocketEnabled = true;
        databaseUrl = "postgresql://${cfg.name}@%2Frun%2Fpostgresql/${cfg.name}";
      };
    };
    systemd.services.vaultwarden.serviceConfig = {
      Group = lib.mkForce cfg.group;
      UMask = lib.mkForce homelab.defaultUMask;
    };
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
    ];

    services.caddy.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };

    services.restic.backups.appdata-local.paths = [
      cfg.dataDir
    ];

    clan.core.vars.generators.vaultwarden = {
      files = {
        admin-token-plaintext = {
          secret = true;
          owner = cfg.name;
        };
        envfile = {
          secret = true;
          owner = cfg.name;
        };
      };
      runtimeInputs = with pkgs; [
        coreutils
        openssl
        libargon2
      ];
      script = ''
        # Generate admin token plaintext (64 random bytes, URL-safe base64)
        openssl rand 64 | openssl base64 -A | tr '+/' '-_' | tr -d '=' > "$out/admin-token-plaintext"

        # Generate random salt for argon2 (16 bytes = 128 bits)
        SALT=$(openssl rand -base64 16 | tr -d '\n')

        # Generate argon2id hash using bitwarden preset: m=64MiB (2^16), t=3, p=4
        # Output format: ADMIN_TOKEN='$argon2id$...'
        HASH=$(echo -n "$(cat "$out/admin-token-plaintext")" | argon2 "$SALT" -id -t 3 -m 16 -p 4 -l 32 -e)

        cat > "$out/envfile" << EOF
        ADMIN_TOKEN='$HASH'
        EOF
      '';
    };
    services.postgresql.ensureUsers = [
      {
        inherit (cfg) name;
        ensureDBOwnership = true;
      }
    ];
    services.postgresql.ensureDatabases = [
      cfg.name
    ];
    services.postgresqlBackup.databases = [
      cfg.name
    ];

    users.users.${cfg.name} = {
      isSystemUser = true;
      description = cfg.name;
      group = lib.mkForce cfg.group;
    };
  };
}
