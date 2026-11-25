{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  inherit (config.settings) username;
  cfg = config.modules.homelab.xandikos;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "xandikos";
    port = 3006;
    domainName = "dav";
    glance.icon = "mdi:calendar-sync";
    gatus = {
      name = "Xandikos";
      group = "services";
      conditions = ["[STATUS] == any(200, 401)"];
    };
  };
  sonarrEnabled = config.modules.homelab.sonarr.enable;
  radarrEnabled = config.modules.homelab.radarr.enable;
in {
  options.modules.homelab.xandikos = service.options;

  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
      services.xandikos = {
        inherit (cfg) port;
        enable = true;
        address = "127.0.0.1";
        nginx.enable = false;
        extraOptions = [
          "--autocreate"
        ];
      };

      services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}".locations =
        {
          "/" = {
            basicAuth.user = username;
            basicAuthFile = config.clan.core.vars.generators.xandikos.files.httpd.path;
          };
        }
        // lib.optionalAttrs sonarrEnabled {
          "/feeds/sonarr.ics" = {
            basicAuth.user = username;
            basicAuthFile = config.clan.core.vars.generators.xandikos.files.httpd.path;
            extraConfig = ''
              include ${config.clan.core.vars.generators.xandikos-sonarr-feed.files.conf.path};
              proxy_pass $sonarr_feed_url;
            '';
          };
        }
        // lib.optionalAttrs radarrEnabled {
          "/feeds/radarr.ics" = {
            basicAuth.user = username;
            basicAuthFile = config.clan.core.vars.generators.xandikos.files.httpd.path;
            extraConfig = ''
              include ${config.clan.core.vars.generators.xandikos-radarr-feed.files.conf.path};
              proxy_pass $radarr_feed_url;
            '';
          };
        };

      clan.core.state.xandikos = {
        folders = [
          cfg.dataDir
        ];
        preBackupScript = ''
          export PATH=${
            lib.makeBinPath [
              config.systemd.package
            ]
          }

          systemctl stop xandikos.service
        '';

        postBackupScript = ''
          export PATH=${
            lib.makeBinPath [
              config.systemd.package
            ]
          }

          systemctl start xandikos.service
        '';
      };

      clan.core.vars.generators.xandikos = {
        share = true;
        files = {
          httpd = {
            owner = "nginx";
            secret = true;
            deploy = true;
          };
        };
        dependencies = [
          "dav"
        ];
        runtimeInputs = with pkgs; [
          apacheHttpd
        ];
        script = ''
          cat $in/dav/passwd | htpasswd -icB $out/httpd "${username}"
        '';
      };

      clan.core.vars.generators.xandikos-sonarr-feed = lib.mkIf sonarrEnabled {
        dependencies = [config.modules.homelab.sonarr.name];
        files.conf = {
          owner = "nginx";
          group = "nginx";
        };
        script = ''
          cat > $out/conf <<EOF
          set \$sonarr_feed_url "http://127.0.0.1:${toString config.modules.homelab.sonarr.port}/feed/v3/calendar/Sonarr.ics?apikey=$(cat $in/${config.modules.homelab.sonarr.name}/apikey)";
          EOF
        '';
      };

      clan.core.vars.generators.xandikos-radarr-feed = lib.mkIf radarrEnabled {
        dependencies = [config.modules.homelab.radarr.name];
        files.conf = {
          owner = "nginx";
          group = "nginx";
        };
        script = ''
          cat > $out/conf <<EOF
          set \$radarr_feed_url "http://127.0.0.1:${toString config.modules.homelab.radarr.port}/feed/v3/calendar/Radarr.ics?apikey=$(cat $in/${config.modules.homelab.radarr.name}/apikey)";
          EOF
        '';
      };
    })
  ];
}
