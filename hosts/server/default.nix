{config, ...}: let
  inherit (config.settings) username;
in {
  imports = [
    ./hardware-configuration.nix
    ./config.nix
  ];

  home-manager.users.${username}.imports = [
    ./home.nix
  ];

  networking = {
    useDHCP = false;
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
