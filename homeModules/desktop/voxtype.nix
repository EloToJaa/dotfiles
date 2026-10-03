{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.desktop.voxtype;
in {
  options.modules.desktop.voxtype = {
    enable = lib.mkEnableOption "Enable Voxtype voice dictation";
  };

  config = lib.mkIf cfg.enable {
    services.voxtype = {
      enable = true;
      package = pkgs.unstable.voxtype-vulkan;
      loadModels = ["base.en"];
      environment = {
        VOXTYPE_OSD_QML_PATH = "${config.services.voxtype.package.src}/quickshell";
        PATH = lib.makeBinPath [
          config.services.voxtype.package
          pkgs.unstable.quickshell
          pkgs.coreutils
          pkgs.which
          pkgs.unstable.wl-clipboard
          pkgs.wtype
        ];
      };
      settings = {
        state_file = "auto";
        osd = {
          enabled = true;
          frontend = "quickshell";
          layout = "tile";
        };
        output = {
          mode = "type";
          fallback_to_clipboard = true;
        };
        hotkey = {
          enabled = true;
          key = "SCROLLLOCK";
          mode = "push_to_talk";
        };
        whisper = {
          model = "base.en";
          language = "en";
          translate = false;
        };
        meeting = {
          enabled = true;
          retain_audio = true;
          summary.backend = "remote";
          diarization = {
            enabled = true;
            backend = "ml";
          };
        };
      };
    };
  };
}
