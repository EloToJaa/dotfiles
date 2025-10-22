{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.core.camera;
in {
  options.modules.core.camera = {
    enable = lib.mkEnableOption "Enable camera module";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      v4l-utils
    ];

    boot = {
      extraModulePackages = with config.boot.kernelPackages; [v4l2loopback.out];

      kernelModules = [
        # Virtual camera
        "v4l2loopback"
        # Virtual microphone
        "snd-aloop"
      ];

      # Set initial kernel module settings
      extraModprobeConfig = ''
        # exclusive_caps: Skype, Zoom, Teams etc. will only show device when actually streaming
        # card_label: Name of virtual camera, how it'll show up in Skype, Zoom, Teams
        # https://github.com/umlaeute/v4l2loopback
        options v4l2loopback video_nr=5 exclusive_caps=1 card_label="Virtual Camera"
      '';
    };
  };
}
