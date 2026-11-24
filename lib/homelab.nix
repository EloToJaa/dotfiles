let
  authzLocation = "/internal/authelia/authz";

  /*
  Config fragment that puts `locations` of the nginx vhosts `domains` behind Authelia
  forward-auth (nginx `auth_request` against Authelia's `/api/authz/auth-request`,
  https://www.authelia.com/integration/proxies/nginx/) and passes `Remote-User`,
  `Remote-Groups`, `Remote-Name` and `Remote-Email` upstream. Authelia is reached at
  `modules.homelab.authelia.forwardAuth.url`.

  `bypass` lists Authelia resource regexes (path and query) that skip authentication on
  `domains`, such as API-key endpoints and health checks. They are added to
  `modules.homelab.authelia.accessControlRules`, which the Authelia host collects.
  */
  mkForwardAuth = {
    lib,
    config,
    domains,
    bypass ? [],
    locations ? ["/"],
  }: {
    modules.homelab.authelia.accessControlRules = lib.optional (bypass != []) {
      domain = domains;
      resources = bypass;
      policy = "bypass";
    };

    services.nginx.virtualHosts = lib.genAttrs domains (_: {
      locations =
        {
          ${authzLocation} = {
            proxyPass = "${config.modules.homelab.authelia.forwardAuth.url}/api/authz/auth-request";
            recommendedProxySettings = false;
            extraConfig = ''
              internal;
              proxy_set_header X-Original-Method $request_method;
              proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
              proxy_set_header X-Forwarded-For $remote_addr;
              proxy_set_header Content-Length "";
              proxy_set_header Connection "";
              proxy_pass_request_body off;
              proxy_ssl_server_name on;
              proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
              proxy_redirect http:// $scheme://;
              proxy_http_version 1.1;
              proxy_cache_bypass $cookie_session;
              proxy_no_cache $cookie_session;
              proxy_buffers 4 32k;
              client_body_buffer_size 128k;
            '';
          };
        }
        // lib.genAttrs locations (_: {
          extraConfig = ''
            auth_request ${authzLocation};
            auth_request_set $authelia_user $upstream_http_remote_user;
            auth_request_set $authelia_groups $upstream_http_remote_groups;
            auth_request_set $authelia_name $upstream_http_remote_name;
            auth_request_set $authelia_email $upstream_http_remote_email;
            proxy_set_header Remote-User $authelia_user;
            proxy_set_header Remote-Groups $authelia_groups;
            proxy_set_header Remote-Name $authelia_name;
            proxy_set_header Remote-Email $authelia_email;
            auth_request_set $authelia_redirect $upstream_http_location;
            error_page 401 =302 $authelia_redirect;
          '';
        });
    });
  };
in {
  inherit mkForwardAuth;

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

  `forwardAuth` is `null` to leave the vhost open by default, otherwise `{ bypass ? [] }`
  to put it behind Authelia (see `mkForwardAuth`). Either way the service gets
  `forwardAuth.enable` and `forwardAuth.bypass` options. A non-empty Gatus `path` is
  bypassed too, so the health check keeps reaching the service.
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
    forwardAuth ? null,
  }: let
    inherit (config.modules) homelab;
    cfg = homelab.${name};
    domain = "${cfg.domainName}.${homelab.baseDomain}";
    domains = [domain] ++ lib.optional mainDomain "${cfg.domainName}.${homelab.mainDomain}";
    gatusBypass = lib.optional (gatus != null && (gatus.path or "") != "") "^${lib.escapeRegex gatus.path}$";
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
        forwardAuth = {
          enable =
            lib.mkEnableOption "Authelia forward-auth in front of the ${name} vhost"
            // {default = forwardAuth != null;};
          bypass = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = forwardAuth.bypass or [];
            description = "Authelia resource regexes that skip forward-auth, such as API-key endpoints";
          };
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

    config = lib.mkIf cfg.enable (lib.mkMerge [
      (lib.mkIf cfg.forwardAuth.enable (mkForwardAuth {
        inherit lib config domains;
        bypass = cfg.forwardAuth.bypass ++ gatusBypass;
      }))
      {
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
      }
    ]);
  };

  /*
  Clan vars generator for an Authelia OIDC client whose service runs on another
  machine than Authelia. `share = true` keeps a single value in `vars/shared/`, so
  the service machine reads `client-secret` and the Authelia machine reads
  `client-secret-hash`. Owners may differ per machine; everything else must be
  identical on every machine that declares the generator.
  */
  mkSharedOidcSecret = {
    pkgs,
    secretOwner ? "root",
    hashOwner ? "root",
  }: {
    share = true;
    runtimeInputs = [
      pkgs.pwgen
      pkgs.gnused
      pkgs.unstable.authelia
    ];
    files = {
      client-secret.owner = secretOwner;
      client-secret-hash.owner = hashOwner;
    };
    script = ''
      pwgen -s 64 1 | tr -d '\n' > "$out/client-secret"
      authelia crypto hash generate pbkdf2 --no-confirm --password "$(cat "$out/client-secret")" \
        | sed 's/^Digest: //' | tr -d '\n' > "$out/client-secret-hash"
    '';
  };
}
