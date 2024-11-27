{variables, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./../../modules/base
  ];

  home-manager.users.${variables.username}.imports = [
    ./../../modules/home
  ];

  powerManagement.cpuFreqGovernor = "performance";
}
