{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.quizer;
in {
  options.modules.homelab.quizer = {
    enable = lib.mkEnableOption "Enable quizer";
    name = lib.mkOption {
      type = lib.types.str;
      default = "quizer";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "quiz";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.main;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3010;
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.name} = {
      isSystemUser = true;
      description = cfg.name;
      group = cfg.group;
    };

    services.quizer = {
      enable = true;
      package = inputs.quizer.packages.${pkgs.system}.quizer;
      user = cfg.name;
      group = cfg.group;
      inherit (cfg) port;
      environment = {
        ASPNETCORE_URLS = "http://127.0.0.1:${toString cfg.port}";
      };
    };

    services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };
  };
}
