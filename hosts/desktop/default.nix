{variables, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./../../modules/base
    ./../../modules/core
  ];

  home-manager.users.${variables.username}.imports = [
    ./../../modules/home
    ./../../modules/desktop
  ];

  networking.interfaces.eth0.ipv4.addresses = [
    {
      address = "192.168.0.20";
      prefixLength = 24;
    }
  ];

  powerManagement.cpuFreqGovernor = "performance";
}
