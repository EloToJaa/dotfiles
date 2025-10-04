{
  variables,
  config,
  ...
}: let
  inherit (variables) homelab timezone;
  name = "cleanuparr";
  domainName = "cleanuparr";
  dataDir = "${homelab.varDataDir}${name}/${name}";
  port = 11011;
  pid = 1000;
  id = 378;
in {
  virtualisation.oci-containers.containers.cleanuparr = {
    image = "ghcr.io/cleanuparr/cleanuparr:latest";
    autoStart = true;
    podman = {
      user = name;
      sdnotify = "conmon";
    };
    serviceName = name;
    extraOptions = [
      "--cgroup-manager=cgroupfs"
    ];
    environment = {
      PORT = toString port;
      PUID = toString pid;
      PGID = toString pid;
      TZ = timezone;
      UMASK = homelab.defaultUMask;
    };
    volumes = [
      "${dataDir}:/config"
    ];
    ports = ["127.0.0.1:${toString port}:${toString port}"];
  };
  systemd.tmpfiles.rules = [
    "d ${homelab.varDataDir}${name} 770 ${name} ${name} - -"
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
    home = "/var/lib/${name}";
    autoSubUidGidRange = true;
    linger = true;
  };
  users.groups.${name}.gid = id;
}
