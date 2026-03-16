{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.settings) email;
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.nginx;
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
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      package = pkgs.nginx;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = builtins.listToAttrs (lib.concatMap (domain: [
          {
            name = domain;
            value = {
              forceSSL = true;
              useACMEHost = domain;
              locations."/".return = "444";
              extraConfig = ''
                add_header X-Frame-Options SAMEORIGIN always;
                add_header X-Content-Type-Options nosniff always;
                add_header X-XSS-Protection "1; mode=block" always;
              '';
            };
          }
        ])
        cfg.baseDomains);
    };

    systemd.services.nginx.serviceConfig.UMask = lib.mkForce homelab.defaultUMask;
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
              CF_DNS_API_TOKEN_FILE = config.sops.secrets."cloudflare/apitoken".path;
            };
          };
        })
        cfg.baseDomains);
    };

    users.users.${cfg.name}.extraGroups = [cfg.group];

    sops.secrets = {
      "cloudflare/apitoken" = {
        owner = "acme";
      };
    };
  };
}
