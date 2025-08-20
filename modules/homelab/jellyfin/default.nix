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
  services.${name} = {
    enable = true;
    package = pkgs.unstable.jellyfin;
    user = name;
    inherit group dataDir logDir;
  };
  systemd.services.${name}.serviceConfig.UMask = lib.mkForce homelab.defaultUMask;
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

  nixpkgs.overlays = [
    (_: prev: {
      jellyfin-web = prev.jellyfin-web.overrideAttrs (
        _: _: {
          installPhase = ''
            runHook preInstall

            # this is the important line
            sed -i "s#</head>#<script src=\"configurationpage?name=skip-intro-button.js\"></script></head>#" dist/index.html

            mkdir -p $out/share
            cp -a dist $out/share/jellyfin-web

            runHook postInstall
          '';
        }
      );
    })
  ];
}
