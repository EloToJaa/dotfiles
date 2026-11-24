{
  /*
  Common parts of a `modules.homelab.<name>` service, returned as `{ options, config }`
  for the service module to merge into its own `options.modules.homelab.<name>` and
  `config`. Merging in place, not importing a separate module, keeps the
  service's Gatus endpoint at the same position in the merged endpoint list.

  `name` is the option namespace and the default of `serviceName`, the `name` option
  default (user, unit and state directory name). `serviceName = null` omits the `name`
  option for services that have none.

  `options` declares `enable`, `name`, `domainName`, `port` and, unless `dataDir`
  is false, `dataDir`. `config` (guarded by `enable`) adds an nginx vhost proxying
  `<domainName>.<baseDomain>` to the loopback port (and `<domainName>.<mainDomain>` when
  `mainDomain` is true), a Gatus endpoint and forces
  `homelab.defaultUMask` on the systemd units in `umaskUnits`.

  `gatus` is `null` to skip the endpoint, otherwise `{ name, group, path ? "",
  conditions ? ["[STATUS] == 200"] }`. Point `path` at the service's health endpoint
  and only fall back to the root URL with `conditions = ["[STATUS] < 400"]`.
  */
  mkHomelabService = {
    lib,
    config,
    name,
    port,
    serviceName ? name,
    description ? "Enable ${name}",
    domainName ? name,
    dataDir ? true,
    proxyWebsockets ? true,
    mainDomain ? false,
    gatus ? null,
    umaskUnits ? [],
  }: let
    inherit (config.modules) homelab;
    cfg = homelab.${name};
    domain = "${cfg.domainName}.${homelab.baseDomain}";
  in {
    options =
      {
        enable = lib.mkEnableOption description;
        domainName = lib.mkOption {
          type = lib.types.str;
          default = domainName;
        };
        port = lib.mkOption {
          type = lib.types.port;
          default = port;
        };
      }
      // lib.optionalAttrs (serviceName != null) {
        name = lib.mkOption {
          type = lib.types.str;
          default = serviceName;
        };
      }
      // lib.optionalAttrs dataDir {
        dataDir = lib.mkOption {
          type = lib.types.path;
          default = "${homelab.varDataDir}${cfg.name}";
        };
      };

    config = lib.mkIf cfg.enable {
      modules.homelab.gatus.endpoints = lib.optional (gatus != null) {
        inherit (gatus) name group;
        url = "https://${domain}${gatus.path or ""}";
        conditions = gatus.conditions or ["[STATUS] == 200"];
      };

      systemd.services = lib.genAttrs umaskUnits (_: {
        serviceConfig.UMask = lib.mkForce homelab.defaultUMask;
      });

      services.nginx.virtualHosts = let
        mkVirtualHost = acmeHost: {
          forceSSL = true;
          useACMEHost = acmeHost;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}";
            inherit proxyWebsockets;
          };
        };
      in
        {
          ${domain} = mkVirtualHost homelab.baseDomain;
        }
        // lib.optionalAttrs mainDomain {
          "${cfg.domainName}.${homelab.mainDomain}" = mkVirtualHost homelab.mainDomain;
        };
    };
  };
}
