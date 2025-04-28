{variables, ...}: let
  name = "caddy";
  homelab = variables.homelab;
in {
  services.${name} = {
    enable = true;
    user = "${name}";
    group = "${homelab.group}";
    dataDir = "${homelab.dataDir}${name}";

    globalConfig = ''
      auto_https off
    '';
    virtualHosts = {
      "http://${homelab.baseDomain}" = {
        extraConfig = ''
          redir https://{host}{uri}
        '';
      };
      "http://*.${homelab.baseDomain}" = {
        extraConfig = ''
          redir https://{host}{uri}
        '';
      };
    };
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
