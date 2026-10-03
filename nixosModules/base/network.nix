{
  host,
  pkgs,
  lib,
  config,
  inputs,
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
    clan.core.vars.generators.tailscale = lib.mkIf cfg.tailscale.enable {
      prompts.auth-key = {
        description = "Tailscale auth key";
        type = "hidden";
      };
      files.auth-key = {
        secret = true;
      };
      share = true;
      script = ''
        cat $prompts/auth-key > $out/auth-key
      '';
    };
    environment.systemPackages = [
      # Clan otherwise chooses Zenity whenever a graphical session is present,
      # even in a terminal. Prefer dialog for terminal input, retaining the GUI fallback.
      (inputs.clan-core.packages.${pkgs.stdenv.hostPlatform.system}.clan-cli.overrideAttrs (old: {
        postPatch =
          (old.postPatch or "")
          + ''
            # Prefer terminal askpass when Clan is launched interactively.
            substituteInPlace clan_lib/ssh/remote.py \
              --replace-fail \
                'elif os.environ.get("DISPLAY") or os.environ.get("WAYLAND_DISPLAY"):' \
                'elif not sys.stdin.isatty() and (os.environ.get("DISPLAY") or os.environ.get("WAYLAND_DISPLAY")):'
          '';
      }))
    ];
    networking = {
      hostName = host;
      networkmanager = {
        enable = true;
        dns = "systemd-resolved";
        settings.connectivity.uri = "http://nmcheck.gnome.org/check_network_status.txt";
      };
      firewall.enable = lib.mkDefault true;
      nameservers = dns;
    };
    services.resolved = {
      enable = true;
      settings.Resolve = {
        DNSSEC = "false";
        Domains = ["~."];
        FallbackDNS = dns;
        DNSOverTLS = "opportunistic";
      };
    };
    networking.firewall.trustedInterfaces = lib.mkIf cfg.tailscale.enable [interfaceName];
    services.tailscale = lib.mkIf cfg.tailscale.enable {
      enable = true;
      inherit interfaceName;
      package = pkgs.unstable.tailscale;
      # Enable caddy to acquire certificates from the tailscale daemon
      # - https://tailscale.com/blog/caddy
      permitCertUid = lib.mkIf config.services.nginx.enable "nginx";
      openFirewall = true;
      useRoutingFeatures = "both";
      authKeyFile = config.clan.core.vars.generators.tailscale.files.auth-key.path;
    };
    users.users.${username}.extraGroups = [
      "networkmanager"
    ];

    # Workaround https://github.com/NixOS/nixpkgs/issues/180175
    systemd.services.NetworkManager-wait-online.enable = lib.mkIf config.networking.networkmanager.enable false;
  };
}
