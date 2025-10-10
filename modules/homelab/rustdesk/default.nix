{pkgs, ...}: {
  services.rustdesk-server = {
    enable = true;
    package = pkgs.unstable.rustdesk-server;
    openFirewall = true;
    relay.enable = true;
    signal = {
      enable = true;
      # relayHosts = ["127.0.0.1"];
    };
  };

  # services.caddy.virtualHosts."${domainName}.${homelab.baseDomain}" = {
  #   useACMEHost = homelab.baseDomain;
  #   extraConfig = ''
  #     reverse_proxy http://127.0.0.1:${toString port}
  #   '';
  # };
}
