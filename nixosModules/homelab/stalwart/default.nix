{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = homelab.stalwart;
  domain = "${cfg.domainName}.${homelab.mainDomain}";
  certificate = homelab.mainDomain;
  credentialsDir = "/run/credentials/stalwart.service";
in {
  options.modules.homelab.stalwart = {
    enable = lib.mkEnableOption "Enable the Stalwart mail server";
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "mail";
      description = "Subdomain under the homelab main domain used as the mail server hostname.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8085;
      description = "Local port of the HTTP listener (web admin, JMAP) proxied by nginx.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.stalwart = {
      enable = true;
      stateVersion = "26.05";
      credentials = {
        admin_password = config.clan.core.vars.generators.stalwart-admin.files.password.path;
        tls_cert = "/var/lib/acme/${certificate}/fullchain.pem";
        tls_key = "/var/lib/acme/${certificate}/key.pem";
      };
      settings = {
        server = {
          hostname = domain;
          tls = {
            enable = true;
            implicit = false;
            certificate = "default";
          };
          listener = {
            smtp = {
              bind = ["[::]:25"];
              protocol = "smtp";
            };
            submission = {
              bind = ["[::]:587"];
              protocol = "smtp";
            };
            submissions = {
              bind = ["[::]:465"];
              protocol = "smtp";
              tls.implicit = true;
            };
            imaps = {
              bind = ["[::]:993"];
              protocol = "imap";
              tls.implicit = true;
            };
            sieve = {
              bind = ["[::]:4190"];
              protocol = "managesieve";
            };
            http = {
              bind = ["127.0.0.1:${toString cfg.port}"];
              protocol = "http";
            };
          };
        };
        certificate.default = {
          cert = "%{file:${credentialsDir}/tls_cert}%";
          private-key = "%{file:${credentialsDir}/tls_key}%";
          default = true;
        };
        authentication.fallback-admin = {
          user = "admin";
          secret = "%{file:${credentialsDir}/admin_password}%";
        };
      };
    };

    # HTTP (web admin, JMAP) stays on localhost behind nginx.
    networking.firewall.allowedTCPPorts = [25 465 587 993 4190];

    systemd.services.stalwart = {
      wants = ["acme-${certificate}.service"];
      after = ["acme-${certificate}.service"];
    };
    security.acme.certs.${certificate}.reloadServices = ["stalwart.service"];

    clan.core.vars.generators.stalwart-admin = {
      files.password = {};
      runtimeInputs = [pkgs.pwgen];
      script = ''
        mkdir -p "$out"
        pwgen -s 32 1 | tr -d '\n' > "$out/password"
      '';
    };

    services.nginx.virtualHosts.${domain} = {
      forceSSL = true;
      useACMEHost = certificate;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 50M;
        '';
      };
    };

    clan.core.state.stalwart = {
      folders = [config.services.stalwart.dataDir];
      preBackupScript = ''
        export PATH=${lib.makeBinPath [config.systemd.package]}
        systemctl stop stalwart.service
      '';
      postBackupScript = ''
        export PATH=${lib.makeBinPath [config.systemd.package]}
        systemctl start stalwart.service
      '';
    };
  };
}
