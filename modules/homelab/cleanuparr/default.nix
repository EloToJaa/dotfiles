{variables, ...}: let
  inherit (variables) homelab timezone;
  name = "cleanuparr";
  domainName = "cleanuparr";
  dataDir = "${homelab.varDataDir}${name}";
  port = 11011;
  id = 378;
in {
  virtualisation.oci-containers.containers.cleanuparr = {
    image = "ghcr.io/cleanuparr/cleanuparr:latest";
    autoStart = true;
    # podman = {
    #   user = name;
    #   sdnotify = "container";
    # };
    serviceName = name;
    extraOptions = [
      "--network=host"
    ];
    environment = {
      PORT = toString port;
      PUID = toString id;
      PGID = toString id;
      TZ = timezone;
      UMASK = homelab.defaultUMask;
    };
    volumes = [
      "${dataDir}:/config"
    ];
    # ports = ["127.0.0.1:${toString port}:${toString port}"];
  };
  systemd.tmpfiles.rules = [
    "d ${dataDir} 770 ${name} ${name} - -"
  ];

  services.restic.backups.appdata-local.paths = [
    dataDir
  ];

  services.caddy.virtualHosts."${domainName}.${homelab.baseDomain}" = {
    useACMEHost = homelab.baseDomain;
    extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString port}
    '';
  };

  users.users.${name} = {
    uid = id;
    group = name;
    description = name;
    home = dataDir;
  };
  users.groups.${name}.gid = id;
}
