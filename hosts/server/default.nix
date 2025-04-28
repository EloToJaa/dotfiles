{
  variables,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./../../modules/base
    ./../../modules/homelab
  ];

  home-manager.users.${variables.username}.imports = [
    ./../../modules/home
  ];

  networking = {
    useDHCP = false;
    nameservers = ["192.168.0.31" "9.9.9.9" "149.112.112.112"];
    firewall = {
      enable = lib.mkForce true;
      allowedTCPPorts = [
        22
        53
        80
        443
      ];
      allowedUDPPorts = [
        53
      ];
    };
    interfaces."enp1s0".ipv4.addresses = [
      {
        address = "192.168.0.32";
        prefixLength = 24;
      }
    ];
    defaultGateway = {
      address = "192.168.0.1";
      interface = "enp1s0";
    };
  };

  powerManagement.cpuFreqGovernor = "performance";
}
