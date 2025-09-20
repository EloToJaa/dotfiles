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
      ports.dns = 53; # Port for incoming DNS Queries.
      upstreams.groups.default = [
        "https://dns.quad9.net/dns-query"
        "https://one.one.one.one/dns-query"
      ];
      # For initially solving DoH/DoT Requests when no system Resolver is available.
      bootstrapDns = [
        {
          upstream = "https://one.one.one.one/dns-query";
          ips = ["1.1.1.1" "1.0.0.1"];
        }
        {
          upstream = "https://dns.quad9.net/dns-query";
          ips = ["9.9.9.9" "149.112.112.112"];
        }
      ];
      #Enable Blocking of certain domains.
      blocking = {
        denylists = {
          #Adblocking
          ads = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"];
        };
        #Configure what block categories are used
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
        mapping.${baseDomain} = "192.168.0.32";
      };
    };
  };

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
