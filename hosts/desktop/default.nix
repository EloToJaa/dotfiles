{variables, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./../../modules/base
    ./../../modules/core
  ];

  home-manager.users.${variables.username}.imports = [
    ./../home
    ./../desktop
  ];

  powerManagement.cpuFreqGovernor = "performance";
}
