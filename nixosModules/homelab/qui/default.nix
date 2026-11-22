{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.qui;
in {
  options.modules.homelab.qui = {
    enable = lib.mkEnableOption "Enable qui, a qBittorrent web UI";
    name = lib.mkOption {
      type = lib.types.str;
      default = "qui";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "qui";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 7476;
    };
  };
  config = lib.mkIf cfg.enable {
    modules.homelab.gatus.endpoints = [
      {
        name = "qui";
        group = "media";
        url = "https://${cfg.domainName}.${homelab.baseDomain}/health";
        conditions = ["[STATUS] == 200"];
      }
    ];

    services.qui = {
      enable = true;
      package = pkgs.unstable.qui;
      secretFile = config.clan.core.vars.generators.${cfg.name}.files.session-secret.path;
      settings = {
        host = "127.0.0.1";
        inherit (cfg) port;
      };
    };

    clan.core.vars.generators.${cfg.name} = {
      files.session-secret = {};
      runtimeInputs = [pkgs.openssl];
      script = ''
        openssl rand -hex 32 | tr -d '\n' > $out/session-secret
      '';
    };

    clan.core.state.${cfg.name} = {
      folders = ["/var/lib/qui"];
      preBackupScript = ''
        export PATH=${lib.makeBinPath [config.systemd.package]}

        systemctl stop qui.service
      '';
      postBackupScript = ''
        export PATH=${lib.makeBinPath [config.systemd.package]}

        systemctl start qui.service
      '';
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
