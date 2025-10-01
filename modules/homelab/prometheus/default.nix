{
  variables,
  pkgs,
  ...
}: let
  inherit (variables) homelab;
  name = "prometheus";
  domainName = "prometheus";
  group = variables.homelab.groups.main;
  stateDir = "${homelab.varDataDir}${name}";
  port = 9090;
in {
  services.prometheus = {
    enable = true;
    package = pkgs.unstable.prometheus;
    inherit port stateDir;
  };
  systemd.tmpfiles.rules = [
    "d ${stateDir} 750 ${name} ${group} - -"
  ];

  services.caddy.virtualHosts."${domainName}.${homelab.baseDomain}" = {
    useACMEHost = homelab.baseDomain;
    extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString port}
    '';
  };

  services.restic.backups.appdata-local.paths = [
    stateDir
  ];

  # services.prometheus.exporters.node = {
  #   enable = true;
  #   enabledCollectors = [
  #     "systemd"
  #   ];
  # };
}
