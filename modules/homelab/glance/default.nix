{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.glance;
in {
  options.modules.homelab.glance = {
    enable = lib.mkEnableOption "Glance module";
    name = lib.mkOption {
      type = lib.types.str;
      default = "glance";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "home";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.main;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8081;
    };
  };
  config = lib.mkIf cfg.enable {
    services.glance = {
      enable = true;
      package = pkgs.unstable.glance;
      settings = {
        server.port = cfg.port;
        pages = [
          {
            name = "Home";
            columns = [
              {
                size = "full";
                widgets = [{type = "calendar";}];
              }
              {
                size = "full";
                widgets = [{type = "rss";}];
              }
            ];
          }
        ];
      };
    };

    services.caddy.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };

    users.users.${cfg.name} = {
      isSystemUser = true;
      group = lib.mkForce cfg.group;
    };
  };
}
