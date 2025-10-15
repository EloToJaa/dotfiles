{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.ntfy;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
in {
  options.modules.homelab.ntfy = {
    enable = lib.mkEnableOption "Ntfy module";
    name = lib.mkOption {
      type = lib.types.str;
      default = "ntfy-sh";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "ntfy";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.main;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3005;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
  };
  config = lib.mkIf cfg.enable {
    services.ntfy-sh = {
      inherit (cfg) group;
      enable = true;
      package = pkgs.unstable.ntfy-sh;
      user = cfg.name;
      settings = {
        listen-http = "127.0.0.1:${toString cfg.port}";
        cache-file = "${cfg.dataDir}/cache.db";
        attachment-cache-dir = "${cfg.dataDir}/attachments";
        base-url = "https://${domain}";
        behind-proxy = true;
      };
    };
    systemd.services.paperless = {
      environment = {
        NTFY_AUTH_FILE = "${cfg.dataDir}/auth.db";
        NTFY_ENABLE_LOGIN = "true";
        NTFY_AUTH_DEFAULT_ACCESS = "deny-all";
      };
      serviceConfig = {
        Group = cfg.group;
        UMask = lib.mkForce homelab.defaultUMask;
        EnvironmentFile = config.sops.templates."${cfg.name}.env".path;
        StateDirectory = lib.mkForce null;
        DynamicUser = lib.mkForce false;
        ProtectSystem = lib.mkForce "off";
      };
    };
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
    ];

    services.caddy.virtualHosts.${domain} = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };

    services.restic.backups.appdata-local.paths = [
      cfg.dataDir
    ];

    users.users.${cfg.name} = {
      isSystemUser = true;
      description = cfg.name;
      group = lib.mkForce cfg.group;
    };

    sops.secrets = {
      "${cfg.name}/authusers" = {
        owner = cfg.name;
      };
    };
    sops.templates."${cfg.name}.env" = {
      content = ''
        NTFY_AUTH_USERS=${config.sops.placeholder."${cfg.name}/authusers"}
      '';
      owner = cfg.name;
    };
  };
}
