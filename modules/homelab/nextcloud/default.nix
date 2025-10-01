{
  variables,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (variables) homelab;
  name = "nextcloud";
  domainName = "cloud";
  group = variables.homelab.groups.docs;
  dataDir = "${homelab.varDataDir}${name}";
in {
  services.nextcloud = {
    enable = true;
    # package = pkgs.unstable.nextcloud;
    home = dataDir;
    datadir = "/mnt/Data/nextcloud";
    # environmentFile = config.sops.templates."${name}.env".path;
    database.createLocally = true;
    autoUpdateApps.enable = true;
    appstoreEnable = true;
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

  sops.secrets = {
    "${name}/openaiapikey" = {
      owner = name;
    };
  };
  sops.templates."${name}.env" = {
    content = ''
      OPENAI_API_KEY=${config.sops.placeholder."${name}/openaiapikey"}
    '';
    owner = name;
  };
}
