{variables, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./../../modules/base
  ];

  home-manager.users.${variables.username}.imports = [
    ./../home
  ];

  powerManagement.cpuFreqGovernor = "performance";
}
