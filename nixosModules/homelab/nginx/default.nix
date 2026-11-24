{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.settings) email;
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.nginx;
  secretArgsRegex = lib.concatStringsSep "|" cfg.secretArgs;
  secretPathsRegex = lib.concatStringsSep "|" cfg.secretPaths;
in {
  options.modules.homelab.nginx = {
    enable = lib.mkEnableOption "Enable nginx";
    name = lib.mkOption {
      type = lib.types.str;
      default = "nginx";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.main;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
    logDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.logDir}${cfg.name}";
    };
    baseDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        homelab.mainDomain
        homelab.baseDomain
      ];
    };

    accessLogTag = lib.mkOption {
      type = lib.types.strMatching "[A-Za-z0-9_]{1,32}";
      default = "nginx_access";
      description = "Syslog tag of the JSON access log that nginx sends to the journal, which Alloy uses to label it job=\"nginx\"";
    };
    secretArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "[a-z0-9_.-]*(key|token|secret|password|passwd|signature)"
        "sig"
        "auth"
        "code"
      ];
      example = ["X-Plex-Token"];
      description = "Case-insensitive regexes matching query parameter names that carry secrets. Requests with any of them are not traced, because the span records the full request URI, and their query string is left out of the access log.";
    };
    secretPaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "/webhooks?/"
        "/share/"
      ];
      description = "Case-insensitive regexes matching URI paths that embed secrets, such as webhook tokens or share links. Matching requests are not traced, and the access log replaces the rest of their path with <redacted>.";
    };
    tracing.enable =
      lib.mkEnableOption "OpenTelemetry tracing of every request, sent to the local Alloy"
      // {default = homelab.alloy.enable;};
  };

  config = lib.mkIf cfg.enable {
    services.prometheus.exporters.nginx = {
      enable = true;
      listenAddress = "127.0.0.1";
      scrapeUri = "http://127.0.0.1/nginx_status";
    };
    modules.homelab.prometheus.scrapeTargets = [
      {
        job_name = "nginx";
        address = "127.0.0.1:${toString config.services.prometheus.exporters.nginx.port}";
      }
    ];

    services.nginx = {
      enable = true;
      # nginxModules.otel is only packaged in nixpkgs-unstable
      package =
        if cfg.tracing.enable
        then pkgs.unstable.nginx
        else pkgs.nginx;
      additionalModules = lib.optional cfg.tracing.enable pkgs.unstable.nginxModules.otel;
      prependConfig = lib.mkIf cfg.tracing.enable ''
        load_module ${config.services.nginx.package}/modules/ngx_otel_module.so;
      '';
      appendHttpConfig = lib.mkMerge [
        ''
          add_header X-Frame-Options SAMEORIGIN always;
          add_header X-Content-Type-Options nosniff always;
          add_header Referrer-Policy strict-origin-when-cross-origin always;
          add_header Strict-Transport-Security "max-age=31536000" always;
        ''
        ''
          map $uri $access_log_path {
            "~*^(?<access_log_path_prefix>.*?(?:${secretPathsRegex}))" "$access_log_path_prefix<redacted>";
            default $uri;
          }

          map $args $access_log_query {
            "~*(^|&)(${secretArgsRegex})=" "";
            "" "";
            default "?$args";
          }

          log_format json_access escape=json '{'
            '"time":"$time_iso8601",'
            '"vhost":"$server_name",'
            '"host":"$host",'
            '"remote_addr":"$remote_addr",'
            '"method":"$request_method",'
            '"uri":"$access_log_path$access_log_query",'
            '"protocol":"$server_protocol",'
            '"status":$status,'
            '"bytes_sent":$body_bytes_sent,'
            '"request_time":$request_time,'
            '"upstream_response_time":"$upstream_response_time",'
            '"user_agent":"$http_user_agent"'
            ${lib.optionalString cfg.tracing.enable "',\"trace_id\":\"$otel_trace_id\"'"}
          '}';

          access_log syslog:server=unix:/dev/log,tag=${cfg.accessLogTag},nohostname json_access;
        ''
        (lib.mkIf cfg.tracing.enable ''
          map $args $otel_trace_args {
            "~*(^|&)(${secretArgsRegex})=" off;
            default on;
          }

          map $uri $otel_trace_enabled {
            /nginx_status off;
            "~*(${secretPathsRegex})" off;
            default $otel_trace_args;
          }

          otel_exporter {
            endpoint 127.0.0.1:${toString homelab.alloy.otlpGrpcPort};
          }
          otel_service_name nginx;
          otel_trace $otel_trace_enabled;
          otel_trace_context propagate;
        '')
      ];
      statusPage = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      proxyTimeout = "600s";
      recommendedTlsSettings = true;

      virtualHosts =
        builtins.listToAttrs (lib.concatMap (domain: [
            {
              name = domain;
              value = {
                forceSSL = true;
                useACMEHost = domain;
                locations."/".return = "444";
              };
            }
          ])
          cfg.baseDomains)
        // {
          # Explicit default server so hostnames without a vhost get a 404
          # instead of whichever vhost happens to sort first.
          "_" = {
            default = true;
            forceSSL = true;
            useACMEHost = homelab.baseDomain; # wildcard cert covers *.<host>.<mainDomain>
            locations."/".return = "404";
          };
        };
    };

    systemd.services.nginx.serviceConfig.UMask = lib.mkForce homelab.defaultUMask;
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
    ];

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    security.acme = {
      acceptTerms = true;
      defaults.email = email;
      certs = builtins.listToAttrs (map (domain: {
          name = domain;
          value = {
            inherit domain;
            inherit (cfg) group;
            reloadServices = ["nginx.service"];
            extraDomainNames = ["*.${domain}"];
            dnsProvider = "cloudflare";
            dnsResolver = "1.1.1.1:53";
            dnsPropagationCheck = true;
            credentialFiles = {
              CF_DNS_API_TOKEN_FILE = config.clan.core.vars.generators.cloudflare.files.apitoken.path;
            };
          };
        })
        cfg.baseDomains);
    };

    users.users.${cfg.name}.extraGroups = [cfg.group];

    clan.core.vars.generators.cloudflare = {
      share = true;
      prompts.apitoken = {
        description = "Cloudflare API token with DNS edit permission";
        type = "hidden";
        persist = true;
      };
      files.apitoken.owner = "acme";
    };
  };
}
