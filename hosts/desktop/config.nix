{
  networking = {
    useDHCP = false;
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

  imports = [
    ./../../nixosModules
  ];
  modules = {
    base = {
      enable = true;
      bootloader.enable = true;
      docker.enable = true;
      index.enable = true;
      tailscale.enable = true;
      nfs.enable = true;
      nh.enable = true;
      ssh.enable = true;
    };
    core = {
      enable = true;
      adb.enable = false;
      audio.enable = true;
      bluetooth.enable = true;
      camera.enable = true;
      gnome.enable = true;
      mullvad.enable = true;
      security.enable = true;
      steam.enable = false;
      virtualization.enable = true;
      wayland.enable = true;
      xserver.enable = true;
    };
  };
}
