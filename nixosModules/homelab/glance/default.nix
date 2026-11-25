{
  lib,
  config,
  inputs,
  outputs,
  ...
}: let
  inherit (lib) mkOption types;
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

  siteType = types.submodule {
    options = {
      title = mkOption {
        type = types.str;
        description = "Name shown on the dashboard";
      };
      group = mkOption {
        type = types.str;
        description = "Monitor widget the site is listed in";
      };
      url = mkOption {
        type = types.str;
        description = "URL the site links to";
      };
      checkUrl = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "URL Glance requests for the up/down status, `url` when null";
      };
      icon = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Glance icon such as `di:sonarr`, see https://github.com/glanceapp/glance/blob/main/docs/configuration.md#icons";
      };
      description = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Tooltip shown when hovering the site";
      };
    };
  };

  sites =
    cfg.sites
    ++ lib.concatMap (
      host: inputs.self.nixosConfigurations.${host}.config.modules.homelab.glance.sites
    )
    cfg.hosts;

  toGlanceSite = site:
    {
      inherit (site) title url;
    }
    // lib.optionalAttrs (site.checkUrl != null) {check-url = site.checkUrl;}
    // lib.optionalAttrs (site.icon != null) {inherit (site) icon;}
    // lib.optionalAttrs (site.description != null) {inherit (site) description;};

  monitorWidgets =
    lib.mapAttrsToList (group: groupSites: {
      type = "monitor";
      title = group;
      cache = "1m";
      sites = map toGlanceSite (lib.sortOn (site: lib.toLower site.title) groupSites);
    })
    (lib.groupBy (site: site.group) sites);
in {
  options.modules.homelab.glance =
    service.options
    // {
      hosts = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Other hosts whose Glance sites are shown on this dashboard.";
      };
      sites = mkOption {
        type = types.listOf siteType;
        default = [];
        description = "Sites shown on the Glance dashboard, grouped into monitor widgets. Each homelab module appends its own.";
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
