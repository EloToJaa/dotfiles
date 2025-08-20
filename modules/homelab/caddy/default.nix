{
  variables,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (variables) homelab;
  name = "caddy";
  group = variables.homelab.groups.main;
  dataDir = "${homelab.dataDir}${name}";
  logDir = "${homelab.logDir}${name}";
in {
  services.${name} = {
    inherit group dataDir logDir;
    enable = true;
    package = pkgs.unstable.caddy;
    user = name;

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
  systemd.services.${name}.serviceConfig.UMask = lib.mkForce homelab.defaultUMask;
  systemd.tmpfiles.rules = [
    "d ${homelab.dataDir}${name} 750 ${name} ${group} - -"
    "d ${homelab.logDir}${name} 750 ${name} ${group} - -"
  ];

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "elotoja@protonmail.com";
    certs.${homelab.baseDomain} = {
      inherit group;
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

  users.users.${name} = {
    inherit group;
    isSystemUser = true;
    description = name;
  };

  sops.secrets = {
    "cloudflare/apitoken" = {
      owner = "acme";
    };
  };
}
