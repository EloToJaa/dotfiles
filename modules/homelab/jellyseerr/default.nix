{
  variables,
  lib,
  ...
}: let
  name = "jellyseerr";
  domainName = "request";
  homelab = variables.homelab;
  group = variables.homelab.groups.homelab;
  port = 5055;
in {
  services.${name} = {
    enable = true;
    user = "${name}";
    group = "${group}";
    configDir = "${homelab.dataDir}${name}";
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

  services.postgresql.ensureUsers = [
    {
      name = name;
      ensureDBOwnership = false;
    }
  ];
  services.postgresql.ensureDatabases = [
    "${name}"
  ];

  users.users.${name} = {
    isSystemUser = true;
    description = "${name}";
    group = "${group}";
  };
}
