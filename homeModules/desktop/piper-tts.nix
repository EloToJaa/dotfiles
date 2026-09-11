{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.desktop.piper-tts;

  voiceModel = pkgs.fetchurl {
    name = "en_US-lessac-medium.onnx";
    url = "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/medium/en_US-lessac-medium.onnx";
    hash = "sha256-Xv4J5pkCGHgnr2RuGm6dJp3udp+Yd9F7FrG0buqvAZ8=";
  };

  voiceConfig = pkgs.fetchurl {
    name = "en_US-lessac-medium.onnx.json";
    url = "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/medium/en_US-lessac-medium.onnx.json";
    hash = "sha256-7+GcQXvtBV8taZCCSMa6ZQ+hNbyGiw5quz2hgdq2kKA=";
  };

  piper = pkgs.piper-tts.override {
    withAlignment = false;
    withHTTP = false;
    withTrain = false;
  };

  speakSelection = pkgs.writeShellApplication {
    name = "piper-speak-selection";
    runtimeInputs = [
      pkgs.libnotify
      piper
      pkgs.pipewire
      pkgs.wl-clipboard
    ];
    text = ''
      text="$(wl-paste --primary --no-newline 2>/dev/null || true)"

      if [[ -z "''${text//[[:space:]]/}" ]]; then
        notify-send "Piper" "Select some text first"
        exit 1
      fi

      audio_file="$(mktemp "''${XDG_RUNTIME_DIR:-/tmp}/piper-selected-text.XXXXXX.wav")"
      trap 'rm -f "$audio_file"' EXIT

      printf '%s\n' "$text" | piper \
        --model ${voiceModel} \
        --config ${voiceConfig} \
        --output-file "$audio_file"
      pw-play "$audio_file"
    '';
  };

  toggleSelection = pkgs.writeShellApplication {
    name = "piper-toggle-selection";
    runtimeInputs = [pkgs.systemd];
    text = ''
      if systemctl --user is-active --quiet piper-selected-text.service; then
        systemctl --user stop --no-block piper-selected-text.service
      else
        systemctl --user start --no-block piper-selected-text.service
      fi
    '';
  };
in {
  options.modules.desktop.piper-tts.enable =
    lib.mkEnableOption "Piper text-to-speech for selected text";

  config = lib.mkIf cfg.enable {
    home.packages = [toggleSelection];

    systemd.user.services.piper-selected-text = {
      Unit.Description = "Speak selected text with Piper";
      Service = {
        ExecStart = lib.getExe speakSelection;
        KillMode = "control-group";
      };
    };
  };
}
