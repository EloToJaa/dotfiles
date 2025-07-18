{
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
  hardware.enableRedistributableFirmware = true;
  services.fstrim.enable = true;
}
