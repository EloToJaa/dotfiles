{
  variables,
  lib,
  ...
}: let
  name = "qbittorrent";
  domainName = "download";
  homelab = variables.homelab;
  group = variables.homelab.groups.main;
  port = 8181;
in {
  imports = [./service.nix];
  services.${name} = {
    enable = true;
    port = port;
    user = "${name}";
    group = "${group}";
    dataDir = "${homelab.dataDir}${name}";
  };
  systemd.services.${name}.serviceConfig.UMask = lib.mkForce homelab.defaultUMask;
  systemd.tmpfiles.rules = [
    "d ${homelab.dataDir}${name} 750 ${name} ${group} - -"
  ];

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
