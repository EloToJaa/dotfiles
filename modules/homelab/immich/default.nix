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
  containers.${name} = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "127.0.0.1";
    hostAddress6 = "::1";
    localAddress6 = "fc00::2";
    config = {...}: {
      services.${name} = {
        enable = true;
        # user = name;
        # group = group;
        host = "127.0.0.1";
        port = port;
        openFirewall = true;
        accelerationDevices = ["/dev/dri/renderD128"];
        mediaLocation = mediaDir;
        database = {
          enable = true;
          createDB = false;
          port = 5433;
          name = name;
          # user = name;
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
          enable = true;
          allowedTCPPorts = [5433];
        };
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
      };

      services.resolved.enable = true;

      # users.users.${name} = {
      #   isSystemUser = true;
      #   description = name;
      #   group = lib.mkForce group;
      #   extraGroups = [
      #     "video"
      #     "render"
      #   ];
      # };
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
  networking.firewall.allowedTCPPorts = [5433];
}
