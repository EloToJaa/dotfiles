{
  variables,
  lib,
  ...
}: let
  name = "immich";
  domainName = "photos";
  homelab = variables.homelab;
  group = variables.homelab.groups.photos;
  port = 2283;
  dbPort = 5433;
  mediaDir = "/mnt/Photos";
  dataDir = "${homelab.varDataDir}nixos-containers/${name}${homelab.varDataDir}";
  host = "192.168.100.11";
in {
  containers.${name} = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = host;
    hostAddress6 = "fc00::1";
    localAddress6 = "fc00::2";
    config = {...}: {
      services.${name} = {
        enable = true;
        user = name;
        group = group;
        host = host;
        port = port;
        openFirewall = true;
        # accelerationDevices = ["/dev/dri/renderD128"];
        mediaLocation = "/data";
        database = {
          enable = true;
          createDB = true;
          port = dbPort;
          name = name;
          user = name;
        };
        redis = {
          enable = true;
          port = 0; # disable tcp
        };
        machine-learning = {
          enable = true;
        };
        settings = {
          newVersionCheck.enabled = true;
          server.externalDomain = "https://${domainName}.${homelab.baseDomain}";
        };
      };
      systemd.services.${name}.serviceConfig = {
        UMask = lib.mkForce homelab.defaultUMask;
      };
      systemd.tmpfiles.rules = [
        "d ${homelab.varDataDir}${name} 750 ${name} ${group} - -"
      ];

      system.stateVersion = variables.stateVersion;

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [5433];
        };
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
      };

      services.resolved.enable = true;

      users.users.${name} = {
        isSystemUser = true;
        description = name;
        group = lib.mkForce group;
        # extraGroups = [
        #   "video"
        #   "render"
        # ];
      };
      users.groups = {
        ${homelab.groups.photos}.gid = 1102;
      };
    };
    forwardPorts = [
      {
        containerPort = dbPort;
        hostPort = dbPort;
        protocol = "tcp";
      }
      {
        containerPort = port;
        hostPort = port;
        protocol = "tcp";
      }
    ];
    bindMounts.mediaLocation = {
      isReadOnly = false;
      hostPath = mediaDir;
      mountPoint = "/data";
    };
  };

  services.caddy.virtualHosts."${domainName}.${homelab.baseDomain}" = {
    useACMEHost = homelab.baseDomain;
    extraConfig = ''
      reverse_proxy http://${host}:${toString port}
    '';
  };
  services.restic.backups.appdata-local.paths = [
    dataDir
    mediaDir
  ];
  networking.firewall.allowedTCPPorts = [dbPort];
}
