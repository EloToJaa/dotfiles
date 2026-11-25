{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.ntfy;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "ntfy";
    port = 3005;
    serviceName = "ntfy-sh";
    glance.icon = "di:ntfy";
    gatus = {
      name = "ntfy";
      group = "monitoring";
      path = "/v1/health";
    };
  };
  domain = "${cfg.domainName}.${homelab.baseDomain}";
in {
  options.modules.homelab.ntfy =
    service.options
    // {
      group = lib.mkOption {
        type = lib.types.str;
        default = homelab.groups.main;
      };
    };
  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
      services.ntfy-sh = {
        inherit (cfg) group;
        enable = true;
        package = pkgs.unstable.ntfy-sh;
        user = cfg.name;
        settings = {
          listen-http = "0.0.0.0:${toString cfg.port}";
          cache-file = "${cfg.dataDir}/cache.db";
          attachment-cache-dir = "${cfg.dataDir}/attachments";
          base-url = "https://${domain}";
          behind-proxy = true;
          auth-file = "${cfg.dataDir}/user.db";
          auth-default-access = "deny-all";
          enable-login = true;
        };
      };
      networking.firewall.interfaces.wg-host.allowedTCPPorts =
        lib.mkIf config.services.wireguard-netns.enable [cfg.port];

      clan.core.state.ntfy = {
        folders = [
          cfg.dataDir
        ];
        preBackupScript = ''
          export PATH=${
            lib.makeBinPath [
              config.systemd.package
            ]
          }

          systemctl stop ntfy-sh.service
        '';

        postBackupScript = ''
          export PATH=${
            lib.makeBinPath [
              config.systemd.package
            ]
          }

          systemctl start ntfy-sh.service
        '';
      };

      users.users.${cfg.name} = {
        isSystemUser = true;
        description = cfg.name;
        group = lib.mkForce cfg.group;
      };
    })
  ];
}
