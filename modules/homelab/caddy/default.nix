{variables, ...}: let
  name = "caddy";
  homelab = variables.homelab;
in {
  services.${name} = {
    enable = true;
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
      webroot = "${homelab.dataDir}acme";
      reloadServices = ["caddy.service"];
      domain = "${homelab.baseDomain}";
      extraDomainNames = ["*.${homelab.baseDomain}"];
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      dnsPropagationCheck = true;
      group = "${homelab.group}";
      environmentFile = homelab.cloudflare.dnsCredentialsFile;
    };
  };

  systemd.tmpfiles.rules = [
    "d ${homelab.dataDir}${name} 750 ${name} ${homelab.group} - -"
    "d ${homelab.dataDir}acme 750 ${name} ${homelab.group} - -"
  ];

  users.users.${name} = {
    isSystemUser = true;
    description = "${name}";
    group = "${homelab.group}";
  };
}
