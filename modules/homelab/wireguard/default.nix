{config, ...}: let
  name = "wireguard";
  privateIP = "10.73.69.202";
  dnsIP = "10.64.0.1";
in {
  imports = [
    ./service.nix
  ];

  services."${name}-netns" = {
    enable = true;
    configFile = config.age.secrets.wireguardCredentials.path;
    privateIP = privateIP;
    dnsIP = dnsIP;
  };

  sops.secrets = {
    "${name}/privatekey" = {
      owner = name;
    };
    "${name}/publickey" = {
      owner = name;
    };
    "${name}/endpoint" = {
      owner = name;
    };
  };
  sops.templates = {
    "config-${name}.xml" = {
      content = ''
        [Interface]
        PrivateKey = ${config.sops.placeholder."${name}/privatekey"}
        Address = ${privateIP}/32
        DNS = ${dnsIP}

        [Peer]
        PublicKey = ${config.sops.placeholder."${name}/publickey"}
        AllowedIPs = 0.0.0.0/0,::0/0
        Endpoint = ${config.sops.placeholder."${name}/endpoint"}
      '';
      owner = name;
    };
  };
}
