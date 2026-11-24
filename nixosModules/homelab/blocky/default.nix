{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.blocky;
  dns = {
    quad9 = "https://dns.quad9.net/dns-query";
    cloudflare = "https://one.one.one.one/dns-query";
  };
in {
  options.modules.homelab.blocky = {
    enable = lib.mkEnableOption "Enable blocky";
    name = lib.mkOption {
      type = lib.types.str;
      default = "blocky";
    };
    metricsPort = lib.mkOption {
      type = lib.types.port;
      default = 4000;
      description = "Loopback port of Blocky's HTTP listener, which serves /metrics";
    };
    queryLog = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = homelab.postgres.enable;
        description = "Store DNS query logs in the local PostgreSQL database";
      };
      retentionDays = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 30;
        description = "Delete query log entries older than this many days, 0 keeps them forever";
      };
    };
  };
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf cfg.queryLog.enable {
      # The build-time check reads the query log target, which only exists at runtime.
      services.blocky.enableConfigCheck = false;
      services.blocky.settings.queryLog = {
        type = "postgresql";
        target = "file:/run/credentials/blocky.service/dsn";
        logRetentionDays = cfg.queryLog.retentionDays;
      };
      systemd.services.blocky = {
        after = ["postgresql.target"];
        wants = ["postgresql.target"];
        serviceConfig.LoadCredential = "dsn:${config.clan.core.vars.generators."${cfg.name}-dsn".files.dsn.path}";
      };

      clan.core.postgresql = {
        databases.${cfg.name} = {
          create = {
            enable = true;
            options = {
              LC_COLLATE = "C";
              LC_CTYPE = "C";
              ENCODING = "UTF8";
              OWNER = cfg.name;
              TEMPLATE = "template0";
            };
          };
          restore.stopOnRestore = ["blocky.service"];
        };
        users.${cfg.name} = {};
      };

      clan.core.vars.generators = {
        ${cfg.name} = {
          files.pgpassword.deploy = false;
          runtimeInputs = [pkgs.pwgen];
          script = ''
            pwgen -s 64 1 | tr -d '\n' > "$out/pgpassword"
          '';
        };
        "${cfg.name}-dsn" = {
          dependencies = [cfg.name];
          files.dsn = {};
          script = ''
            printf 'postgres://${cfg.name}:%s@127.0.0.1:${toString homelab.postgres.port}/${cfg.name}?sslmode=disable' \
              "$(cat "$in/${cfg.name}/pgpassword")" > "$out/dsn"
          '';
        };
      };
    })
    {
      modules.homelab.gatus.endpoints = [
        {
          name = "Blocky";
          group = "infrastructure";
          url = "127.0.0.1";
          dns = {
            query-name = "${homelab.mainDomain}";
            query-type = "A";
          };
          conditions = ["[DNS_RCODE] == NOERROR"];
        }
      ];

      modules.homelab.prometheus.scrapeTargets = [
        {
          job_name = "blocky";
          address = "127.0.0.1:${toString cfg.metricsPort}";
        }
      ];

      services.blocky = {
        enable = true;
        package = pkgs.unstable.blocky;
        settings = {
          ports = {
            dns = 53;
            tls = 853;
            http = "127.0.0.1:${toString cfg.metricsPort}";
          };
          prometheus.enable = true;
          upstreams.groups.default = [
            dns.quad9
            dns.cloudflare
          ];
          # For initially solving DoH/DoT Requests when no system Resolver is available.
          bootstrapDns = [
            {
              upstream = dns.quad9;
              ips = ["9.9.9.9" "149.112.112.112"];
            }
            {
              upstream = dns.cloudflare;
              ips = ["1.1.1.1" "1.0.0.1"];
            }
          ];
          #Enable Blocking of certain domains.
          blocking = {
            denylists = {
              ads = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"];
            };
            clientGroupsBlock = {
              default = ["ads"];
            };
          };
          caching = {
            minTime = "5m";
            maxTime = "30m";
            prefetching = true;
          };
          customDNS = {
            customTTL = "1h";
            mapping = {
              "kvm.${homelab.mainDomain}" = homelab.hosts.kvm;
              "server.${homelab.mainDomain}" = homelab.hosts.server;
              "worker.${homelab.mainDomain}" = homelab.hosts.worker;
              "nas.${homelab.mainDomain}" = homelab.hosts.nas;
              "pve.${homelab.mainDomain}" = homelab.hosts.pve;
            };
          };
        };
      };

      services.resolved = lib.mkIf config.services.resolved.enable {
        settings = {
          Resolve = {
            DNS = ["127.0.0.1"];
            DNSOverTLS = lib.mkForce "false";
            DNSStubListener = false;
          };
        };
      };

      networking.firewall = {
        allowedTCPPorts = [
          53
          853
        ];
        allowedUDPPorts = [
          53
        ];
      };
    }
  ]);
}
