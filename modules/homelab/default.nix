{
  lib,
  config,
  ...
}: let
  cfg = config.homelab;
in {
  # options.homelab = {
  #   enable = lib.mkEnableOption "The homelab services and configuration variables";
  #   timeZone = lib.mkOption {
  #     default = "Europe/Warsaw";
  #     type = lib.types.str;
  #     description = ''
  #       Time zone to be used for the homelab services
  #     '';
  #   };
  #   mainDomain = lib.mkOption {
  #     default = "";
  #     type = lib.types.str;
  #     description = ''
  #       Base domain name to be used to access the homelab services via Caddy reverse proxy
  #     '';
  #   };
  #   baseDomain = lib.mkOption {
  #     default = "";
  #     type = lib.types.str;
  #     description = ''
  #       Base domain name to be used to access the homelab services via Caddy reverse proxy
  #     '';
  #   };
  #   dataDir = lib.mkOption {
  #     default = "/opt/";
  #     type = lib.types.str;
  #     description = ''
  #       Base directory to be used for the homelab services data
  #     '';
  #   };
  #   varDataDir = lib.mkOption {
  #     default = "/var/lib/";
  #     type = lib.types.str;
  #     description = ''
  #       Base directory to be used for the homelab services data
  #     '';
  #   };
  #   logDir = lib.mkOption {
  #     default = "/var/log/";
  #     type = lib.types.str;
  #     description = ''
  #       Base directory to be used for the homelab services logs
  #     '';
  #   };
  #   defaultUMask = lib.mkOption {
  #     default = "027";
  #     type = lib.types.str;
  #     description = ''
  #       Default umask to be used for the homelab services
  #     '';
  #   };
  #   groups.main = lib.mkOption {
  #     type = lib.types.str;
  #     default = "homelab";
  #     description = "Main homelab group";
  #   };
  #   groups.media = lib.mkOption {
  #     type = lib.types.str;
  #     default = "media";
  #     description = "Media group";
  #   };
  #   groups.photos = lib.mkOption {
  #     type = lib.types.str;
  #     default = "photos";
  #     description = "Photos group";
  #   };
  #   groups.docs = lib.mkOption {
  #     type = lib.types.str;
  #     default = "documents";
  #     description = "Documents group";
  #   };
  #   groups.database = lib.mkOption {
  #     type = lib.types.str;
  #     default = "database";
  #     description = "Database group";
  #   };
  #   groups.backups = lib.mkOption {
  #     type = lib.types.str;
  #     default = "backups";
  #     description = "Backups group";
  #   };
  # };
  imports = [
    ./atuin
    ./backup
    ./bazarr
    ./bind
    ./caddy
    ./glance
    # ./grafana
    ./immich
    ./jellyfin
    ./jellyseerr
    ./karakeep
    # ./loki
    ./paperless
    ./postgres
    # ./prometheus
    ./prowlarr
    ./qbittorrent
    ./radarr
    ./radicale
    ./redis
    ./sonarr
    ./uptime
    ./vaultwarden
    ./wireguard
    ./firewall.nix
    ./nat.nix
  ];
}
