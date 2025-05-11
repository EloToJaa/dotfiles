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
  mediaDir = "/mnt/Data/${name}";
in {
  services.${name} = {
    enable = true;
    user = name;
    group = group;
    host = "127.0.0.1";
    port = port;
    accelerationDevices = ["/dev/dri/renderD128"];
    mediaLocation = mediaDir;
    database = {
      enable = true;
      createDB = false;
      port = port + 1;
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
    "d ${mediaDir} 750 ${name} ${group} - -"
  ];

  services.caddy.virtualHosts."${domainName}.${homelab.baseDomain}" = {
    useACMEHost = homelab.baseDomain;
    extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString port}
    '';
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
}
