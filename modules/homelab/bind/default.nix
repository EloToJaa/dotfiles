{
  variables,
  pkgs,
  ...
}: let
  name = "bind";
  homelab = variables.homelab;
  baseDomain = homelab.mainDomain;
in {
  services.${name} = {
    enable = false;
    ipv4Only = false;
    extraOptions = ''
      dnssec-validation auto;
    '';
    forwarders = [
      "9.9.9.9"
      "149.112.112.112"
      "2620:fe::fe"
      "2620:fe::9"
    ];
    zones = {
      "${baseDomain}" = {
        master = true;
        file = pkgs.writeText "${baseDomain}.zone" ''
          $TTL 2d
          $ORIGIN ${baseDomain}.
          @       IN      SOA     ns.${baseDomain}. elotoja.protonmail.com. (2025050600 12h 15m 3w 2h)
          @       IN      NS      ns.${baseDomain}.
          ns      IN      A       192.168.0.32

          server   IN      A       192.168.0.32
          *.server IN      A       192.168.0.32
          nas      IN      A       192.168.0.41
        '';
      };
    };
  };
}
