{
  variables,
  lib,
  ...
}: let
  name = "uptime-kuma";
  domainName = "uptime";
  homelab = variables.homelab;
  group = variables.homelab.groups.main;
  port = 3001;
  dataDir = "${homelab.dataDir}${name}";
in {
  services.${name} = {
    enable = true;
    settings = {
      DATA_DIR = lib.mkForce dataDir;
      PORT = lib.mkForce (toString port);
    };
  };
  systemd.services.${name}.serviceConfig = {
    User = lib.mkForce name;
    Group = lib.mkForce group;
    UMask = lib.mkForce homelab.defaultUMask;
    StateDirectory = lib.mkForce null;
    DynamicUser = lib.mkForce false;
    ProtectSystem = lib.mkForce "off";
  };

  services.caddy.virtualHosts."${domainName}.${homelab.baseDomain}" = {
    useACMEHost = homelab.baseDomain;
    extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString port}
    '';
  };

  services.restic.backups.appdata-local.paths = [
    dataDir
  ];

  users.users.${name} = {
    isSystemUser = true;
    group = lib.mkForce group;
  };
}
