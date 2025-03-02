{pkgs, ...}: {
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # lowLatency.enable = true;
  };
  hardware.pulseaudio.enablePersistence = true;
  environment.systemPackages = with pkgs; [
    pulseaudioFull
  ];
}
