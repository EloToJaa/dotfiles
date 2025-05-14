{
  variables,
  config,
  ...
}: let
  name = "wireguard-netns";
in {
  imports = [
    ./service.nix
  ];

  services.${name} = {
    enable = true;
    configFile = config.age.secrets.wireguardCredentials.path;
    privateIP = "10.100.0.2";
    dnsIP = "10.64.0.1";
  };
}
