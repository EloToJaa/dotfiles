{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.radicale;
in {
  options.modules.homelab.radicale = {
    enable = lib.mkEnableOption "Enable radicale";
    name = lib.mkOption {
      type = lib.types.str;
      default = "radicale";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "dav";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.main;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 5232;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.dataDir}${cfg.name}";
    };
  };
  config = lib.mkIf cfg.enable {
    services.radicale = {
      enable = true;
      package = pkgs.unstable.radicale;
      settings = {
        server.hosts = ["127.0.0.1:${toString cfg.port}"];
        storage.filesystem_folder = cfg.dataDir;
        auth = {
          type = "htpasswd";
          htpasswd_filename = config.sops.secrets."${cfg.name}/htpasswd".path;
          htpasswd_encryption = "plain";
        };
      };
    };
    systemd.services.radicale.serviceConfig = {
      User = lib.mkForce cfg.name;
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

    users.users.${cfg.name} = {
      isSystemUser = true;
      description = lib.mkForce cfg.name;
      group = lib.mkForce cfg.group;
    };

    sops.secrets = {
      "${cfg.name}/htpasswd" = {
        owner = cfg.name;
      };
    };
  };
}
