{
  host,
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (config.modules.settings) dns username;
  cfg = config.modules.base;
in {
  options.modules.base.tailscale = {
    enable = lib.mkEnableOption "Enable tailscale";
  };
  config = lib.mkIf cfg.enable {
    networking = {
      hostName = host;
      networkmanager = {
        enable = true;
        dns = "systemd-resolved";
        settings.connectivity.uri = "http://nmcheck.gnome.org/check_network_status.txt";
      };
      firewall.enable = lib.mkDefault false;
      nameservers = dns;
    };
    services.resolved = {
      enable = true;
      dnssec = "false";
      domains = ["~."];
      fallbackDns = dns;
      dnsovertls = "opportunistic";
    };
    services.tailscale = {
      inherit (cfg.tailscale) enable;
      package = pkgs.tailscale;
      # Enable caddy to acquire certificates from the tailscale daemon
      # - https://tailscale.com/blog/caddy
      permitCertUid = lib.mkIf config.services.caddy.enable "caddy";
      openFirewall = true;
      useRoutingFeatures = "both";
    };
    users.users.${username}.extraGroups = [
      "networkmanager"
    ];

    # Workaround https://github.com/NixOS/nixpkgs/issues/180175
    systemd.services.NetworkManager-wait-online.enable = lib.mkIf config.networking.networkmanager.enable false;
  };
}
