{
  config,
  lib,
  host,
  ...
}: let
  cfg = config.modules.homelab;
in {
  options.modules.homelab = {
    enable = lib.mkEnableOption "Enable homelab module";
    mainDomain = lib.mkOption {
      type = lib.types.str;
      default = "elotoja.com";
    };
    baseDomain = lib.mkOption {
      type = lib.types.str;
      default = "${host}.${cfg.mainDomain}";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/opt/";
    };
    varDataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/";
    };
    logDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/log/";
    };
    defaultUMask = lib.mkOption {
      type = lib.types.str;
      default = "027";
    };
  };
  options.modules.homelab.groups = {
    main = lib.mkOption {
      type = lib.types.str;
      default = "homelab";
    };
    cloud = lib.mkOption {
      type = lib.types.str;
      default = "cloud";
    };
    media = lib.mkOption {
      type = lib.types.str;
      default = "media";
    };
    photos = lib.mkOption {
      type = lib.types.str;
      default = "photos";
    };
    docs = lib.mkOption {
      type = lib.types.str;
      default = "documents";
    };
    database = lib.mkOption {
      type = lib.types.str;
      default = "database";
    };
    backups = lib.mkOption {
      type = lib.types.str;
      default = "backups";
    };
  };
  imports = [
    ./atuin
    ./authelia
    ./backup
    ./bazarr
    ./blocky
    ./caddy
    ./cleanuparr
    ./glance
    ./grafana
    ./home-assistant
    ./immich
    ./jellyfin
    ./jellyseerr
    ./jellystat
    ./karakeep
    ./loki
    ./minecraft
    ./mysql
    ./nextcloud
    ./ntfy
    ./paperless
    ./postgres
    ./profilarr
    ./prometheus
    ./prowlarr
    ./qbittorrent
    ./radarr
    ./radicale
    ./rustdesk
    ./sonarr
    ./uptime
    ./vaultwarden
    ./wireguard
    ./firewall.nix
    ./groups.nix
    ./journald.nix
    ./redis.nix
  ];
}
