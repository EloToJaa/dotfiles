{
  config,
  lib,
  ...
}: let
  cfg = config.modules.homelab.wireguard;
in {
  options.modules.homelab.wireguard = {
    enable = lib.mkEnableOption "Enable wireguard";
    name = lib.mkOption {
      type = lib.types.str;
      default = "wireguard";
    };
    privateIP = lib.mkOption {
      type = lib.types.str;
      default = "10.71.102.82";
    };
    dnsIP = lib.mkOption {
      type = lib.types.str;
      default = "10.64.0.1";
    };
  };
  # Device: Sharp Hare
  # Server: ch-zrh-wg-003
  imports = [
    ./service.nix
  ];
  config = lib.mkIf cfg.enable {
    services."wireguard-netns" = {
      enable = true;
      configFile = config.clan.core.vars.generators."${cfg.name}-config".files."wg0.conf".path;
      inherit (cfg) privateIP dnsIP;
    };

    clan.core.vars.generators.${cfg.name} = {
      prompts = {
        privatekey = {
          description = "WireGuard client private key";
          type = "hidden";
          persist = true;
        };
        publickey = {
          description = "WireGuard server public key";
          type = "hidden";
          persist = true;
        };
        endpoint = {
          description = "WireGuard server IP address";
          type = "hidden";
          persist = true;
        };
      };
      files = {
        privatekey.deploy = false;
        publickey.deploy = false;
        endpoint.deploy = false;
      };
    };
    clan.core.vars.generators."${cfg.name}-config" = {
      dependencies = [cfg.name];
      files."wg0.conf" = {};
      script = ''
        printf '[Interface]\nPrivateKey = %s\n\n[Peer]\nPublicKey = %s\nAllowedIPs = 0.0.0.0/0\nEndpoint = %s:51820\n' \
          "$(cat "$in/${cfg.name}/privatekey")" \
          "$(cat "$in/${cfg.name}/publickey")" \
          "$(cat "$in/${cfg.name}/endpoint")" \
          > "$out/wg0.conf"
      '';
    };
  };
}
