{
  variables,
  lib,
  ...
}: let
  name = "glance";
  domainName = "feed";
  homelab = variables.homelab;
  group = variables.homelab.groups.main;
  port = 8081;
in {
  services.${name} = {
    enable = true;
    settings = {
      server.port = port;
    };
  };

  services.caddy.virtualHosts."${domainName}.${homelab.baseDomain}" = {
    useACMEHost = homelab.baseDomain;
    extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString port}
    '';
  };

  users.users.${name} = {
    isSystemUser = true;
    group = lib.mkForce group;
  };
}
