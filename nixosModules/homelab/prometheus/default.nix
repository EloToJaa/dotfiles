{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.prometheus;
in {
  options.modules.homelab.prometheus = {
    enable = lib.mkEnableOption "Enable prometheus";
    name = lib.mkOption {
      type = lib.types.str;
      default = "prometheus";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "prometheus";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.main;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 9090;
    };
    stateDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
  };
  config = lib.mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      package = pkgs.unstable.prometheus;
      inherit (cfg) port stateDir;
    };
    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 750 ${cfg.name} ${cfg.group} - -"
    ];

    services.caddy.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };

    services.restic.backups.appdata-local.paths = [
      cfg.stateDir
    ];

    # services.prometheus.exporters.node = {
    #   enable = true;
    #   enabledCollectors = [
    #     "systemd"
    #   ];
    # };
  };
}
