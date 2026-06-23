{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  inherit (config.settings) username;
  cfg = config.modules.homelab.xandikos;
  sonarrEnabled = config.modules.homelab.sonarr.enable;
  radarrEnabled = config.modules.homelab.radarr.enable;
  vars = config.clan.core.vars.generators.xandikos;
in {
  options.modules.homelab.xandikos = {
    enable = lib.mkEnableOption "Enable xandikos";
    name = lib.mkOption {
      type = lib.types.str;
      default = "xandikos";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "dav";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3006;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xandikos = {
      inherit (cfg) port;
      enable = true;
      address = "127.0.0.1";
      nginx.enable = false;
      extraOptions = [
        "--autocreate"
      ];
    };

    services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations =
        {
          "/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}";
            proxyWebsockets = true;
            basicAuth.user = username;
            basicAuthFile = config.clan.core.vars.generators.xandikos.files.httpd.path;
          };
        }
        // lib.optionalAttrs sonarrEnabled {
          "/feeds/sonarr.ics" = {
            basicAuth.user = username;
            basicAuthFile = config.clan.core.vars.generators.xandikos.files.httpd.path;
            extraConfig = ''
              include ${vars.files.sonarr-feed.path};
              proxy_pass $sonarr_feed_url;
            '';
          };
        }
        // lib.optionalAttrs radarrEnabled {
          "/feeds/radarr.ics" = {
            basicAuth.user = username;
            basicAuthFile = config.clan.core.vars.generators.xandikos.files.httpd.path;
            extraConfig = ''
              include ${vars.files.radarr-feed.path};
              proxy_pass $radarr_feed_url;
            '';
          };
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
      files =
        {
          httpd = {
            owner = "nginx";
            secret = true;
            deploy = true;
          };
        }
        // lib.optionalAttrs sonarrEnabled {
          sonarr-feed = {
            owner = "nginx";
            group = "nginx";
            secret = true;
          };
        }
        // lib.optionalAttrs radarrEnabled {
          radarr-feed = {
            owner = "nginx";
            group = "nginx";
            secret = true;
          };
        };
      dependencies =
        ["dav"]
        ++ lib.optionals sonarrEnabled ["sonarr"]
        ++ lib.optionals radarrEnabled ["radarr"];
      runtimeInputs = with pkgs; [
        apacheHttpd
      ];
      script = ''
        cat $in/dav/passwd | htpasswd -icB $out/httpd "${username}"
        ${lib.optionalString sonarrEnabled ''
                    sonarr_api_key=$(cat "$in/sonarr/apikey")
                    printf 'set $sonarr_feed_url "http://127.0.0.1:${toString config.modules.homelab.sonarr.port}/feed/v3/calendar/Sonarr.ics?apikey=%s";
          ' "$sonarr_api_key" > "$out/sonarr-feed"
        ''}
        ${lib.optionalString radarrEnabled ''
                    radarr_api_key=$(cat "$in/radarr/apikey")
                    printf 'set $radarr_feed_url "http://127.0.0.1:${toString config.modules.homelab.radarr.port}/feed/v3/calendar/Radarr.ics?apikey=%s";
          ' "$radarr_api_key" > "$out/radarr-feed"
        ''}
      '';
    };
  };
}
