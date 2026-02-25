{
  host,
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (config.settings) dns username;
  cfg = config.modules.base;
  interfaceName = "tailscale0";
in {
  options.modules.base.tailscale = {
    enable = lib.mkEnableOption "Enable tailscale";
  };
  config = lib.mkIf cfg.enable {
    # clan.core.vars.generators.tailscale = {
    #   prompts.auth-key = {
    #     description = "Tailscale auth key";
    #     type = "hidden";
    #   };
    #   files.auth-key = {
    #     secret = true;
    #     deploy = true;
    #   };
    #   share = true;
    #   script = ''
    #     cat $prompts/auth-key > $out/auth-key
    #   '';
    # };
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
    networking.firewall.trustedInterfaces = [interfaceName];
    services.tailscale = {
      inherit (cfg.tailscale) enable;
      inherit interfaceName;
      package = pkgs.unstable.tailscale;
      # Enable caddy to acquire certificates from the tailscale daemon
      # - https://tailscale.com/blog/caddy
      permitCertUid = lib.mkIf config.services.caddy.enable "caddy";
      openFirewall = true;
      useRoutingFeatures = "both";
      # authKeyFile = config.clan.core.vars.generators.tailscale.files.auth-key.path;
    };
    users.users.${username}.extraGroups = [
      "networkmanager"
    ];

    # Workaround https://github.com/NixOS/nixpkgs/issues/180175
    systemd.services.NetworkManager-wait-online.enable = lib.mkIf config.networking.networkmanager.enable false;
  };
}
