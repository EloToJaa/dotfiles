{variables, ...}: let
  name = "dnsmasq";
  homelab = variables.homelab;
in {
  services.${name} = {
    enable = true;
    alwaysKeepRunning = true;
    resolveLocalQueries = true;
    settings = {
      server = [
        "9.9.9.9"
        "149.112.112.112"
        "2620:fe::fe"
        "2620:fe::9"
      ];
      address = [
        "/${homelab.baseDomain}/192.168.0.32"
      ];
    };
  };
}
