{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules.homelab) homelab;
  cfg = config.modules.homelab.karakeep;
in {
  options.modules.homelab.karakeep = {
    enable = lib.mkEnableOption "Karakeep module";
    name = lib.mkOption {
      type = lib.types.str;
      default = "karakeep";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "hoarder";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.main;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3003;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
  };
  config = lib.mkIf cfg.enable {
    services.karakeep = {
      enable = true;
      package = pkgs.unstable.karakeep;
      environmentFile = config.sops.templates."${cfg.name}.env".path;
      browser.enable = true;
      meilisearch.enable = true;
      extraEnvironment = {
        NEXTAUTH_URL = "https://${cfg.domainName}.${homelab.baseDomain}";
        DOMAIN = homelab.baseDomain;
        DISABLE_NEW_RELEASE_CHECK = "true";
        PORT = toString cfg.port;
      };
    };
    systemd.services.karakeep.serviceConfig = {
      User = lib.mkForce cfg.name;
      Group = lib.mkForce cfg.group;
      UMask = lib.mkForce homelab.defaultUMask;
    };

    services.caddy.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
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
      group = lib.mkForce cfg.group;
    };

    sops.secrets = {
      "${cfg.name}/openaiapikey" = {
        owner = cfg.name;
      };
    };
    sops.templates."${cfg.name}.env" = {
      content = ''
        OPENAI_API_KEY=${config.sops.placeholder."${cfg.name}/openaiapikey"}
      '';
      owner = cfg.name;
    };
  };
}
