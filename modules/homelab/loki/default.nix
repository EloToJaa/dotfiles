{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.modules.homelab) homelab;
  cfg = config.modules.homelab.loki;
in {
  options.modules.homelab.loki = {
    enable = lib.mkEnableOption "Loki module";
    name = lib.mkOption {
      type = lib.types.str;
      default = "loki";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "loki";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.main;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.dataDir}${cfg.name}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 9090;
    };
  };
  config = lib.mkIf cfg.enable {
    services.loki = {
      inherit (cfg) dataDir group;
      enable = true;
      package = pkgs.unstable.grafana-loki;
      user = cfg.name;
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
  };
}
