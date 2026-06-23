{
  config,
  lib,
  ...
}: let
  cfg = config.modules.homelab.wireguard;
  vars = config.clan.core.vars.generators.${cfg.name};
in {
  options.modules.homelab.wireguard = {
    enable = lib.mkEnableOption "Enable wireguard";
    name = lib.mkOption {
      type = lib.types.str;
      default = "wireguard";
    };
    privateIP = lib.mkOption {
      type = lib.types.str;
      default = "10.74.89.98";
    };
    dnsIP = lib.mkOption {
      type = lib.types.str;
      default = "10.64.0.1";
    };
  };
  imports = [
    ./service.nix
  ];
  config = lib.mkIf cfg.enable {
    services."wireguard-netns" = {
      enable = true;
      configFile = vars.files.wg0-conf.path;
      inherit (cfg) privateIP dnsIP;
    };

    clan.core.vars.generators.${cfg.name} = {
      prompts = {
        privatekey = {
          description = "WireGuard private key";
          type = "hidden";
        };
        publickey = {
          description = "WireGuard peer public key";
          type = "hidden";
        };
        endpoint = {
          description = "WireGuard peer endpoint hostname or address";
          type = "hidden";
        };
      };
      files.wg0-conf.secret = true;
      script = ''
                mkdir -p "$out"
                cat > "$out/wg0-conf" <<EOF
        [Interface]
        PrivateKey = $(cat "$prompts/privatekey")

        [Peer]
        PublicKey = $(cat "$prompts/publickey")
        AllowedIPs = 0.0.0.0/0
        Endpoint = $(cat "$prompts/endpoint"):51820
        EOF
      '';
    };
  };
}
