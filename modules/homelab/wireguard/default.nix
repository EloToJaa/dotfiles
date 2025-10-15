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
      configFile = config.sops.templates."wg0.conf".path;
      inherit (cfg) privateIP dnsIP;
    };

    sops.secrets = {
      "${cfg.name}/privatekey" = {};
      "${cfg.name}/publickey" = {};
      "${cfg.name}/endpoint" = {};
    };
    sops.templates."wg0.conf".content = ''
      [Interface]
      PrivateKey = ${config.sops.placeholder."${cfg.name}/privatekey"}

      [Peer]
      PublicKey = ${config.sops.placeholder."${cfg.name}/publickey"}
      AllowedIPs = 0.0.0.0/0
      Endpoint = ${config.sops.placeholder."${cfg.name}/endpoint"}:51820
    '';
  };
}
