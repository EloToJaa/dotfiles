{
  variables,
  pkgs,
  lib,
  ...
}: let
  inherit (variables.homelab) baseDomain;
in {
  services.blocky = {
    enable = true;
    package = pkgs.unstable.blocky;
    settings = {
      ports = {
        dns = 53;
        tls = 853;
      };
      upstreams.groups.default = [
        "https://dns.quad9.net/dns-query"
        "https://one.one.one.one/dns-query"
      ];
      # For initially solving DoH/DoT Requests when no system Resolver is available.
      bootstrapDns = [
        {
          upstream = "https://dns.quad9.net/dns-query";
          ips = ["9.9.9.9" "149.112.112.112"];
        }
        {
          upstream = "https://one.one.one.one/dns-query";
          ips = ["1.1.1.1" "1.0.0.1"];
        }
      ];
      #Enable Blocking of certain domains.
      blocking = {
        denylists = {
          ads = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"];
        };
        clientGroupsBlock = {
          default = ["ads"];
        };
      };
      caching = {
        minTime = "5m";
        maxTime = "30m";
        prefetching = true;
      };
      customDNS = {
        customTTL = "1h";
        mapping."local.elotoja.com" = "192.168.0.32";
      };
    };
  };

  services.resolved.extraConfig = ''
    DNS=127.0.0.1
    DNSStubListener=no
  '';

  networking.firewall = {
    enable = lib.mkForce true;
    allowedTCPPorts = [
      53
    ];
    allowedUDPPorts = [
      53
    ];
  };
}
