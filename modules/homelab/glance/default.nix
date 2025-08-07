{
  variables,
  lib,
  pkgs,
  ...
}: let
  name = "glance";
  domainName = "home";
  homelab = variables.homelab;
  group = variables.homelab.groups.main;
  port = 8081;
in {
  services.${name} = {
    enable = true;
    package = pkgs.unstable.glance;
    settings = {
      server.port = port;
      pages = [
        {
          name = "Home";
          columns = [
            {
              size = "full";
              widgets = [{type = "calendar";}];
            }
            {
              size = "full";
              widgets = [{type = "rss";}];
            }
          ];
        }
      ];
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
