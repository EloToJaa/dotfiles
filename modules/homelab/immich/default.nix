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
in {
  containers.${name} = {
    autoStart = true;
    privateNetwork = false;
    config = {...}: {
      services.${name} = {
        enable = true;
        user = name;
        group = group;
        host = "127.0.0.1";
        port = port;
        openFirewall = true;
        accelerationDevices = ["/dev/dri/renderD128"];
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

      system.stateVersion = variables.stateVersion;

      networking = {
        firewall = {
          allowedTCPPorts = [5433];
        };
      };

      users.users.${name} = {
        isSystemUser = true;
        description = name;
        group = lib.mkForce group;
        extraGroups = [
          "video"
          "render"
        ];
      };
      users.groups = {
        ${homelab.groups.photos}.gid = 1102;
      };
    };
    bindMounts.mediaLocation = {
      isReadOnly = false;
      hostPath = mediaDir;
      mountPoint = "/data";
    };
  };
  # systemd.services.${name}.serviceConfig = {
  #   UMask = lib.mkForce homelab.defaultUMask;
  # };
  # systemd.tmpfiles.rules = [
  #   "d ${mediaDir} 750 ${name} ${group} - -"
  # ];

  services.caddy.virtualHosts."${domainName}.${homelab.baseDomain}" = {
    useACMEHost = homelab.baseDomain;
    extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString port}
    '';
  };
  networking.firewall.allowedTCPPorts = [dbPort];
}
