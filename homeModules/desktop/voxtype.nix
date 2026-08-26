{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.desktop.voxtype;
  package = pkgs.unstable.voxtype-vulkan;
  model = pkgs.fetchurl {
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin";
    hash = "sha256-oDd5yG3zMjB19eeWyyzlAp8A7Ihp7uP9+4l6/jbG0AI=";
  };
in {
  options.modules.desktop.voxtype = {
    enable = lib.mkEnableOption "Enable Voxtype voice dictation";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [package];

    xdg.configFile."voxtype/config.toml".source = (pkgs.formats.toml {}).generate "voxtype-config.toml" {
      state_file = "auto";

      hotkey = {
        enabled = true;
        key = "SCROLLLOCK";
        mode = "push_to_talk";
      };

      audio = {
        device = "default";
        sample_rate = 16000;
        max_duration_secs = 60;
      };

      whisper = {
        model = toString model;
        language = "en";
        translate = false;
      };

      output = {
        mode = "type";
        fallback_to_clipboard = true;
      };
    };

    systemd.user.services.voxtype = {
      Unit = {
        Description = "Voxtype voice dictation daemon";
        Documentation = "https://voxtype.io";
        PartOf = ["graphical-session.target"];
        After = [
          "graphical-session.target"
          "pipewire.service"
          "pipewire-pulse.service"
        ];
      };

      Service = {
        ExecStart = "${package}/bin/voxtype daemon";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
