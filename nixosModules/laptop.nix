{
  lib,
  config,
  pkgs,
  ...
}: {
  networking = {
    useDHCP = lib.mkForce true;
  };

  environment.systemPackages = with pkgs; [
    acpi
    brightnessctl
    cpupower-gui
    powertop
  ];

  settings.isLaptop = true;

  services = {
    power-profiles-daemon.enable = true;

    upower = {
      enable = true;
      percentageLow = 20;
      percentageCritical = 5;
      percentageAction = 3;
      criticalPowerAction = "PowerOff";
    };

    tlp.settings = {
      CPU_ENERGY_PERF_POLICY_ON_AC = "power";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 1;

      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 1;

      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "performance";

      INTEL_GPU_MIN_FREQ_ON_AC = 500;
      INTEL_GPU_MIN_FREQ_ON_BAT = 500;
      # INTEL_GPU_MAX_FREQ_ON_AC=0;
      # INTEL_GPU_MAX_FREQ_ON_BAT=0;
      # INTEL_GPU_BOOST_FREQ_ON_AC=0;
      # INTEL_GPU_BOOST_FREQ_ON_BAT=0;

      # PCIE_ASPM_ON_AC = "default";
      # PCIE_ASPM_ON_BAT = "powersupersave";
    };
  };

  powerManagement.cpuFreqGovernor = "performance";

  boot = {
    kernelModules = ["acpi_call"];
    extraModulePackages = with config.boot.kernelPackages;
      [
        acpi_call
        cpupower
      ]
      ++ [pkgs.cpupower-gui];
  };

  imports = [
    ./default.nix
  ];
  modules = {
    base = {
      enable = lib.mkDefault true;
      nix-ld.enable = lib.mkDefault true;
      smartd.enable = lib.mkDefault true;
      bootloader.enable = lib.mkDefault true;
      tailscale.enable = lib.mkDefault true;
      ssh.enable = lib.mkDefault true;
      sudo.enable = lib.mkDefault true;
    };
    shared = {
      btop.enable = lib.mkDefault true;
      catppuccin.enable = lib.mkDefault true;
      containers.enable = lib.mkDefault true;
      index.enable = lib.mkDefault true;
      nfs.enable = lib.mkDefault false;
      nh.enable = lib.mkDefault true;
    };
    core = {
      enable = lib.mkDefault true;
      gnupg.enable = lib.mkDefault true;
      developer.enable = lib.mkDefault true;
      plymouth.enable = lib.mkDefault true;
      adb.enable = lib.mkDefault false;
      audio.enable = lib.mkDefault true;
      bluetooth.enable = lib.mkDefault true;
      camera.enable = lib.mkDefault true;
      gnome.enable = lib.mkDefault true;
      mullvad.enable = lib.mkDefault true;
      printing.enable = lib.mkDefault false;
      steam.enable = lib.mkDefault false;
      virtualization.enable = lib.mkDefault true;
      wayland = {
        enable = lib.mkDefault true;
        umbriel.enable = lib.mkDefault true;
      };
    };
  };
}
