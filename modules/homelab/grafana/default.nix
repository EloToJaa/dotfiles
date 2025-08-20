{
  variables,
  pkgs,
  ...
}: let
  inherit (variables) homelab;
  name = "grafana";
  domainName = "grafana";
  group = variables.homelab.groups.main;
  dataDir = "${homelab.dataDir}${name}";
  port = 3002;
in {
  services.grafana = {
    inherit dataDir;
    enable = true;
    package = pkgs.unstable.grafana;
    settings.server = {
      http_port = port;
    };
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
