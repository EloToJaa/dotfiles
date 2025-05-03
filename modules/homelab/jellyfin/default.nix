{
  variables,
  lib,
  ...
}: let
  name = "jellyfin";
  domainName = "watch";
  homelab = variables.homelab;
  group = variables.homelab.groups.media;
  port = 8096;
in {
  services.${name} = {
    enable = true;
    user = "${name}";
    group = "${group}";
    dataDir = "${homelab.dataDir}${name}";
    logDir = "${homelab.logDir}${name}";
  };
  systemd.services.${name}.serviceConfig.UMask = lib.mkForce homelab.defaultUMask;

  services.caddy.virtualHosts."${domainName}.${homelab.baseDomain}" = {
    useACMEHost = homelab.baseDomain;
    extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString port}
    '';
  };

  users.users.${name} = {
    isSystemUser = true;
    description = "${name}";
    group = "${group}";
  };
}
