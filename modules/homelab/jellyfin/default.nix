{variables, ...}: let
  name = "jellyfin";
  domainName = "watch";
  homelab = variables.homelab;
  port = 8096;
in {
  services.${name} = {
    enable = true;
    user = "${name}";
    group = "${homelab.group}";
    dataDir = "${homelab.dataDir}${name}";
  };

  services.caddy.virtualHosts."${domainName}.${homelab.baseDomain}" = {
    useACMEHost = homelab.baseDomain;
    extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString port}
    '';
  };

  systemd.tmpfiles.rules = [
    "d ${homelab.dataDir}${name} 750 ${name} ${homelab.group} - -"
  ];

  users.users.${name} = {
    isSystemUser = true;
    description = "${name}";
    group = "${homelab.group}";
  };
}
