{
  variables,
  lib,
  pkgs,
  ...
}: let
  inherit (variables) homelab;
  name = "jellyfin";
  domainName = "watch";
  group = variables.homelab.groups.media;
  port = 8096;
  dataDir = "${homelab.dataDir}${name}";
  logDir = "${homelab.logDir}${name}";
in {
  imports = [./jellystat.nix];
  services.jellyfin = {
    enable = true;
    package = pkgs.unstable.jellyfin;
    user = name;
    inherit group dataDir logDir;
  };
  systemd.services.jellyfin.serviceConfig.UMask = lib.mkForce homelab.defaultUMask;
  systemd.tmpfiles.rules = [
    "d ${dataDir} 750 ${name} ${group} - -"
    "d ${logDir} 750 ${name} ${group} - -"
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
    isSystemUser = true;
    description = name;
    inherit group;
  };
}
