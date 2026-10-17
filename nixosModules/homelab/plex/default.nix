{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.plex;
in {
  options.modules.homelab.plex = {
    enable = lib.mkEnableOption "Enable plex";
    name = lib.mkOption {
      type = lib.types.str;
      default = "plex";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "plex";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.media;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 32400; # hardcoded by plex
      readOnly = true;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
  };
  config = lib.mkIf cfg.enable {
    services.plex = {
      enable = true;
      package = pkgs.unstable.plex;
      user = cfg.name;
      inherit (cfg) group dataDir openFirewall;
    };
    systemd.services.plex.serviceConfig.UMask = lib.mkForce homelab.defaultUMask;
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
    ];
    clan.core.state.plex = {
      folders = [
        cfg.dataDir
      ];
      preBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl stop plex.service
      '';

      postBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl start plex.service
      '';
    };

    services.nginx.virtualHosts = let
      proxyConfig = {
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_buffering off;
            client_max_body_size 100M;
          '';
        };
      };
    in {
      "${cfg.domainName}.${homelab.baseDomain}" = proxyConfig // {useACMEHost = homelab.baseDomain;};
      "${cfg.domainName}.${homelab.mainDomain}" = proxyConfig // {useACMEHost = homelab.mainDomain;};
    };

    users.users.${cfg.name} = {
      isSystemUser = true;
      description = cfg.name;
      inherit (cfg) group;
    };
  };
}
