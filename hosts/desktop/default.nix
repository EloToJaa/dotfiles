{variables, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./../../modules/base
    ./../../modules/core
    ./../../modules/gaming
  ];

  home-manager.users.${variables.username}.imports = [
    ./../../modules/home
    ./../../modules/dev
    ./../../modules/desktop
    ./../../modules/cybersec
  ];

  networking = {
    useDHCP = false;
    nameservers = ["192.168.0.31" "9.9.9.9" "149.112.112.112"];
    interfaces."eno1".ipv4.addresses = [
      {
        address = "192.168.0.20";
        prefixLength = 24;
      }
    ];
    defaultGateway = {
      address = "192.168.0.1";
      interface = "eno1";
    };
  };

  powerManagement.cpuFreqGovernor = "performance";
}
