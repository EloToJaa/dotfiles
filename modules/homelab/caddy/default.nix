{
  variables,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.caddy;
in {
  options.modules.homelab.caddy = {
    enable = lib.mkEnableOption "Caddy module";
    name = lib.mkOption {
      type = lib.types.str;
      default = "caddy";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.main;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.dataDir}${cfg.name}";
    };
    logDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.logDir}${cfg.name}";
    };
  };
  config = lib.mkIf cfg.enable {
    services.caddy = {
      inherit (cfg) group dataDir logDir;
      enable = true;
      package = pkgs.unstable.caddy;
      user = cfg.name;

      globalConfig = ''
        auto_https off
      '';
      virtualHosts = {
        "http://${homelab.baseDomain}" = {
          extraConfig = ''
            redir https://{host}{uri}
          '';
        };
        "http://*.${homelab.baseDomain}" = {
          extraConfig = ''
            redir https://{host}{uri}
          '';
        };
      };
    };
    systemd.services.caddy.serviceConfig.UMask = lib.mkForce homelab.defaultUMask;
    systemd.tmpfiles.rules = [
      "d ${homelab.dataDir}${cfg.name} 750 ${cfg.name} ${cfg.group} - -"
      "d ${homelab.logDir}${cfg.name} 750 ${cfg.name} ${cfg.group} - -"
    ];

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    security.acme = {
      acceptTerms = true;
      defaults.email = variables.email;
      certs.${homelab.baseDomain} = {
        inherit (cfg) group;
        reloadServices = ["caddy.service"];
        domain = homelab.baseDomain;
        extraDomainNames = ["*.${homelab.baseDomain}"];
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        dnsPropagationCheck = true;
        credentialFiles = {
          CF_DNS_API_TOKEN_FILE = config.sops.secrets."cloudflare/apitoken".path;
        };
      };
    };

    users.users.${cfg.name} = {
      inherit (cfg) group;
      isSystemUser = true;
      description = cfg.name;
    };

    sops.secrets = {
      "cloudflare/apitoken" = {
        owner = "acme";
      };
    };
  };
}
