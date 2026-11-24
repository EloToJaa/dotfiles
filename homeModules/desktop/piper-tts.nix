{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.desktop.piper-tts;

  voiceModel = pkgs.fetchurl {
    name = "en_US-lessac-high.onnx";
    url = "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/high/en_US-lessac-high.onnx";
    hash = "sha256-TKv3w6Y4AXE380oVFlIgMtT+PzgiioQ8ybdk3cvNngk=";
  };

  voiceConfig = pkgs.fetchurl {
    name = "en_US-lessac-high.onnx.json";
    url = "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/high/en_US-lessac-high.onnx.json";
    hash = "sha256-20K5fZhZ8le8FWG47ZgOf7I5hAIFCnTd1svskxqSQS8=";
  };

  voice = pkgs.runCommand "piper-voice-en_US-lessac-high" {} ''
    mkdir -p "$out"
    ln -s ${voiceModel} "$out/en_US-lessac-high.onnx"
    ln -s ${voiceConfig} "$out/en_US-lessac-high.onnx.json"
  '';

  piper = pkgs.unstable.piper-tts.override {
    withAlignment = false;
    withHTTP = false;
    withTrain = false;
  };

  speakClipboard = pkgs.writeShellApplication {
    name = "piper-speak-clipboard";
    runtimeInputs = [
      pkgs.libnotify
      piper
      pkgs.pipewire
      pkgs.wl-clipboard
    ];
    text = ''
      text="$(wl-paste --no-newline 2>/dev/null || true)"

      if [[ -z "''${text//[[:space:]]/}" ]]; then
        notify-send "Piper" "Copy some text first"
        exit 1
      fi

      notify-send "Piper" "Started reading"

      audio_file="$(mktemp "''${XDG_RUNTIME_DIR:-/tmp}/piper-clipboard.XXXXXX.wav")"
      trap 'rm -f "$audio_file"' EXIT

      printf '%s\n' "$text" | piper \
        --model ${voice}/en_US-lessac-high.onnx \
        --output-file "$audio_file"
      pw-play "$audio_file"
    '';
  };

  toggleClipboard = pkgs.writeShellApplication {
    name = "piper-toggle-clipboard";
    runtimeInputs = [pkgs.systemd];
    text = ''
      if systemctl --user is-active --quiet piper-clipboard.service; then
        systemctl --user stop --no-block piper-clipboard.service
      else
        systemctl --user start --no-block piper-clipboard.service
      fi
    '';
  };

  stopReading = pkgs.writeShellApplication {
    name = "piper-stop-reading";
    runtimeInputs = [pkgs.systemd];
    text = ''
      systemctl --user stop --no-block piper-clipboard.service
    '';
  };
in {
  options.modules.desktop.piper-tts.enable =
    lib.mkEnableOption "Piper text-to-speech for clipboard text";

  config = lib.mkIf cfg.enable {
    home.packages = [
      stopReading
      toggleClipboard
    ];

    systemd.user.services.piper-clipboard = {
      Unit.Description = "Speak clipboard text with Piper";
      Service = {
        ExecStart = lib.getExe speakClipboard;
        KillMode = "control-group";
      };
    };
  };
}
