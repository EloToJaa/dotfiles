{
  variables,
  config,
  ...
}: let
  name = "caddy";
  homelab = variables.homelab;
in {
  services.${name} = {
    enable = false;
    user = "${name}";
    group = "${homelab.group}";
    dataDir = "${homelab.dataDir}${name}";

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

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "elotoja@protonmail.com";
    certs.${homelab.baseDomain} = {
      reloadServices = ["caddy.service"];
      domain = "${homelab.baseDomain}";
      extraDomainNames = ["*.${homelab.baseDomain}"];
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      dnsPropagationCheck = true;
      group = "${homelab.group}";
      credentialFiles = {
        CF_DNS_API_TOKEN_FILE = "${config.sops.secrets."cloudflare/apitoken".path}";
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d ${homelab.dataDir}${name} 750 ${name} ${homelab.group} - -"
  ];

  users.users.${name} = {
    isSystemUser = true;
    description = "${name}";
    group = "${homelab.group}";
  };

  sops.secrets = {
    "cloudflare/apitoken" = {
      owner = "acme";
    };
  };
}
