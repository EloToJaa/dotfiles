{config, ...}: let
  name = "wireguard";
  privateIP = "10.74.89.98";
  dnsIP = "10.64.0.1";
in {
  imports = [
    ./service.nix
  ];

  services."${name}-netns" = {
    enable = true;
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
