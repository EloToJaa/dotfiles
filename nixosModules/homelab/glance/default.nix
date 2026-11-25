{
  lib,
  config,
  inputs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.glance;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "glance";
    port = 3012;
    domainName = "home";
    dataDir = false;
    forwardAuth = {};
    gatus = {
      name = "Glance";
      group = "apps";
      path = "/api/healthz";
    };
  };

  gatusEndpoints =
    homelab.gatus.endpoints
    ++ lib.concatMap (
      host: inputs.self.nixosConfigurations.${host}.config.modules.homelab.gatus.endpoints
    )
    homelab.gatus.hosts;

  siteUrl = url: let
    match = builtins.match "(https://[^/]+).*" url;
  in
    if match == null
    then null
    else builtins.head match;

  toSite = endpoint:
    {
      title = endpoint.name;
      url = siteUrl endpoint.url;
      check-url = endpoint.url;
    }
    // lib.optionalAttrs (cfg.icons ? ${endpoint.name}) {
      icon = cfg.icons.${endpoint.name};
    };

  sitesByGroup = lib.groupBy (endpoint: endpoint.group) (
    lib.filter (
      endpoint: siteUrl endpoint.url != null && endpoint.name != "Glance"
    )
    gatusEndpoints
  );

  monitorWidgets =
    lib.mapAttrsToList (group: endpoints: {
      type = "monitor";
      title = group;
      cache = "1m";
      sites = map toSite (lib.sortOn (endpoint: endpoint.name) endpoints);
    })
    sitesByGroup;
in {
  options.modules.homelab.glance =
    service.options
    // {
      icons = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {
          "Alertmanager" = "di:alertmanager";
          "Atuin" = "di:atuin";
          "Authelia" = "di:authelia";
          "Bazarr" = "di:bazarr";
          "Cleanuparr" = "di:cleanuparr";
          "Grafana" = "di:grafana";
          "Harmonia" = "di:nixos";
          "Home Assistant" = "di:home-assistant";
          "Immich" = "di:immich";
          "Jellyfin" = "di:jellyfin";
          "Karakeep" = "di:karakeep";
          "lldap" = "di:lldap";
          "Loki" = "di:loki";
          "Nixbot" = "di:nixos";
          "ntfy" = "di:ntfy";
          "Paperless-ngx" = "di:paperless-ngx";
          "pgAdmin" = "di:pgadmin";
          "Prometheus" = "di:prometheus";
          "Prowlarr" = "di:prowlarr";
          "qBittorrent" = "di:qbittorrent";
          "qui" = "di:qui";
          "Radarr" = "di:radarr";
          "Seerr" = "di:jellyseerr";
          "Sonarr" = "di:sonarr";
          "T3 Code" = "di:vscode";
          "Tempo" = "di:tempo";
          "Vaultwarden" = "di:vaultwarden";
          "Yamtrack" = "di:yamtrack";
          "Zigbee2MQTT" = "di:zigbee2mqtt";
        };
        description = "Glance icons keyed by Gatus endpoint name, see https://github.com/glanceapp/glance/blob/main/docs/configuration.md#icons";
      };
    };

  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
      services.glance = {
        enable = true;
        settings = {
          server = {
            host = "127.0.0.1";
            inherit (cfg) port;
          };
          theme = {
            background-color = "240 21 15";
            contrast-multiplier = 1.2;
            primary-color = "217 92 83";
            positive-color = "115 54 76";
            negative-color = "347 70 65";
          };
          pages = [
            {
              name = "Home";
              columns = [
                {
                  size = "small";
                  widgets = [
                    {
                      type = "clock";
                      hour-format = "24h";
                    }
                    {
                      type = "calendar";
                      first-day-of-week = "monday";
                    }
                    {
                      type = "server-stats";
                      servers = [
                        {
                          type = "local";
                          name = config.networking.hostName;
                        }
                      ];
                    }
                  ];
                }
                {
                  size = "full";
                  widgets =
                    [
                      {
                        type = "search";
                        search-engine = "duckduckgo";
                        autofocus = true;
                      }
                    ]
                    ++ monitorWidgets;
                }
              ];
            }
          ];
        };
      };
    })
  ];
}
