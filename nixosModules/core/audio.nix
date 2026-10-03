{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.core.audio;
in {
  options.modules.core.audio = {
    enable = lib.mkEnableOption "Enable audio module";
  };
  config = lib.mkIf (config.modules.core.enable && cfg.enable) {
    security.rtkit.enable = true;
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # lowLatency.enable = true;
    };
    hardware.alsa.enablePersistence = true;
    environment.systemPackages = with pkgs; [
      pulseaudio # PulseAudio client tools for PipeWire
      # unstable.pwmenu
    ];
  };
}
