{...}: {
  imports = [
    ./hardware-configuration.nix
    ./../../modules/base
  ];

  powerManagement.cpuFreqGovernor = "performance";
}
