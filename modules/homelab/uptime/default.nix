{
  variables,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.uptime;
in {
  options.modules.homelab.uptime = {
    enable = lib.mkEnableOption "Enable uptime";
    name = lib.mkOption {
      type = lib.types.str;
      default = "uptime";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "uptime";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = variables.homelab.groups.main;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3001;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.dataDir}${cfg.name}";
    };
  };
  config = lib.mkIf cfg.enable {
    services.uptime-kuma = {
      enable = true;
      package = pkgs.unstable.uptime-kuma;
      settings = {
        DATA_DIR = lib.mkForce cfg.dataDir;
        PORT = lib.mkForce (toString cfg.port);
      };
    };
    systemd.services.uptime-kuma.serviceConfig = {
      User = lib.mkForce cfg.name;
      Group = lib.mkForce cfg.group;
      UMask = lib.mkForce homelab.defaultUMask;
      StateDirectory = lib.mkForce null;
      DynamicUser = lib.mkForce false;
      ProtectSystem = lib.mkForce "off";
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
  };
}
