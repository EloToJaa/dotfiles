{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.core.audio;
in {
  options.modules.core.audio = {
    enable = lib.mkEnableOption "Enable audio module";
  };
  imports = [];
  config = lib.mkIf cfg.enable {
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
      pulseaudioFull
      # unstable.pwmenu
    ];
  };
}
