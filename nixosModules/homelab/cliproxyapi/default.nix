{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = homelab.cliproxyapi;
  secrets = config.clan.core.vars.generators.cliproxyapi;
in {
  imports = [./service.nix];

  options.modules.homelab.cliproxyapi = {
    enable = lib.mkEnableOption "Enable CLIProxyAPI";

    name = lib.mkOption {
      type = lib.types.str;
      default = "cliproxyapi";
    };

    domainName = lib.mkOption {
      type = lib.types.str;
      default = "cliproxyapi";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8317;
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
  };

  config = lib.mkIf cfg.enable {
    services.cliproxyapi = {
      enable = true;
      package = pkgs.llm-agents.cli-proxy-api;
      user = cfg.name;
      group = cfg.name;
      inherit (cfg) dataDir;
      settings = {
        server = {
          host = "127.0.0.1";
          inherit (cfg) port;
          trusted-proxies = ["127.0.0.1"];
        };
        access.api-keys = [{_secret = secrets.files.api-key.path;}];
        management = {
          allow-remote = true;
          secret-key._secret = secrets.files.management-key.path;
        };
      };
    };

    clan.core.vars.generators.cliproxyapi = {
      files = {
        api-key = {
          owner = cfg.name;
          group = cfg.name;
        };
        management-key = {
          owner = cfg.name;
          group = cfg.name;
        };
      };
      runtimeInputs = [pkgs.pwgen];
      script = ''
        mkdir -p "$out"
        pwgen -s 64 1 > "$out/api-key"
        pwgen -s 64 1 > "$out/management-key"
      '';
    };

    services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
        '';
      };
    };

    clan.core.state.cliproxyapi = {
      folders = [cfg.dataDir];
      preBackupScript = ''
        ${config.systemd.package}/bin/systemctl stop cliproxyapi.service
      '';
      postBackupScript = ''
        ${config.systemd.package}/bin/systemctl start cliproxyapi.service
      '';
    };
  };
}
