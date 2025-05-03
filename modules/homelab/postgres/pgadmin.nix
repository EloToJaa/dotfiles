{
  variables,
  config,
  ...
}: let
  name = "pgadmin";
  domainName = "pgadmin";
  homelab = variables.homelab;
  port = 5050;
in {
  services.${name} = {
    enable = true;
    port = port;
    initialEmail = variables.email;
    initialPasswordFile = config.sops.secrets."pgadmin/password".path;
  };

  sops.secrets = {
    "pgadmin/password" = {
      owner = name;
    };
  };

  services.caddy.virtualHosts."${domainName}.${homelab.baseDomain}" = {
    useACMEHost = homelab.baseDomain;
    extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString port}
    '';
  };
}
