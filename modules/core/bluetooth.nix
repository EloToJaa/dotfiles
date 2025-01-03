{pkgs, ...}: {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;
  systemd.user.services.mpris-proxy = {
    description = "Mpris proxy";
    after = ["network.target" "sound.target"];
    wantedBy = ["default.target"];
    serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
  };

  services.pulseaudio.configFile = pkgs.writeText "default.pa" ''
    load-module module-bluetooth-policy
    load-module module-bluetooth-discover
    ## module fails to load with
    ##   module-bluez5-device.c: Failed to get device path from module arguments
    ##   module.c: Failed to load module "module-bluez5-device" (argument: ""): initialization failed.
    # load-module module-bluez5-device
    # load-module module-bluez5-discover
  '';

  environment.systemPackages = with pkgs; [
    bluez
  ];
}
