{config, ...}: let
  name = "wireguard";
  privateIP = "192.168.2.2/24";
  dnsIP = "10.64.0.1";
in {
  imports = [
    ./service.nix
  ];

  services."${name}-netns" = {
    enable = false;
    configFile = config.sops.templates."wg0.conf".path;
    privateIP = privateIP;
    dnsIP = dnsIP;
  };

  sops.secrets = {
    "${name}/privatekey" = {};
    "${name}/publickey" = {};
    "${name}/endpoint" = {};
  };
  sops.templates = {
    "wg0.conf" = {
      content = ''
        [Interface]
        PrivateKey = ${config.sops.placeholder."${name}/privatekey"}

        [Peer]
        PublicKey = ${config.sops.placeholder."${name}/publickey"}
        AllowedIPs = 0.0.0.0/0
        Endpoint = ${config.sops.placeholder."${name}/endpoint"}:51820
      '';
    };
  };
}
