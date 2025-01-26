{variables, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./../../modules/base
  ];

  home-manager.users.${variables.username}.imports = [
    ./../../modules/home
  ];

  networking = {
    useDHCP = false;
    nameservers = ["192.168.0.31" "1.1.1.1" "1.0.0.1"];
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
