{
  variables,
  pkgs,
  ...
}: let
  inherit (variables) homelab;
  name = "loki";
  domainName = "loki";
  group = variables.homelab.groups.main;
  dataDir = "${homelab.dataDir}${name}";
  port = 9090;
in {
  services.loki = {
    inherit dataDir group;
    enable = true;
    package = pkgs.unstable.grafana-loki;
    user = name;
  };
  systemd.tmpfiles.rules = [
    "d ${dataDir} 750 ${name} ${group} - -"
  ];

  services.caddy.virtualHosts."${domainName}.${homelab.baseDomain}" = {
    useACMEHost = homelab.baseDomain;
    extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString port}
    '';
  };

  services.restic.backups.appdata-local.paths = [
    dataDir
  ];
}
