{
  config,
  lib,
  ...
}: let
  inherit (config.modules) homelab;
  inherit (config.settings) timezone;
  cfg = config.modules.homelab.profilarr;
in {
  options.modules.homelab.profilarr = {
    enable = lib.mkEnableOption "Enable profilarr";
    name = lib.mkOption {
      type = lib.types.str;
      default = "profilarr";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "profilarr";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 6868;
    };
    id = lib.mkOption {
      type = lib.types.int;
      default = 379;
    };
  };
  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.profilarr = {
      image = "docker.io/santiagosayshey/profilarr:latest";
      autoStart = true;
      # podman = {
      #   user = name;
      #   sdnotify = "container";
      # };
      serviceName = cfg.name;
      extraOptions = [
        "--network=host"
      ];
      environment = {
        # PORT = toString cfg.port;
        PUID = toString cfg.id;
        PGID = toString cfg.id;
        TZ = timezone;
        UMASK = homelab.defaultUMask;
      };
      volumes = [
        "${cfg.dataDir}:/config"
      ];
      # ports = ["127.0.0.1:${toString port}:${toString port}"];
    };
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 770 ${cfg.name} ${cfg.name} - -"
    ];

    services.restic.backups.appdata-local.paths = [
      cfg.dataDir
    ];

    services.caddy.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };

    users.users.${cfg.name} = {
      uid = cfg.id;
      group = cfg.name;
      description = cfg.name;
      home = cfg.dataDir;
    };
    users.groups.${cfg.name}.gid = cfg.id;
  };
}
