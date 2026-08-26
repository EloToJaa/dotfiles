{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.crash;
  stateDir = "${config.home.homeDirectory}/.local/state/ai-crash";
  skill = ./skills/diagnose-crash/SKILL.md;
  runtimePath = lib.makeBinPath [pkgs.unstable.python314 pkgs.unstable.bun];

  diagnose-crash = pkgs.writeShellScriptBin "diagnose-crash" ''
    set -euo pipefail

    pid=''${1:?usage: diagnose-crash <pid> [comm] [exe] [signal]}
    [[ $pid =~ ^[0-9]+$ ]] || {
      echo "Not a PID: $pid" >&2
      exit 1
    }

    comm=''${2:-unknown}
    exe=''${3:-unknown}
    signal=''${4:-unknown}
    when=$(coredumpctl list "$pid" --no-pager --no-legend 2>/dev/null | tail -1 | cut -d' ' -f1-4) || true
    when=''${when:-unknown}

    prompt=$(cat <<PROMPT
    A process crashed on this machine and I want to know why.

    What systemd-coredump recorded:
      process:  $comm
      PID:      $pid
      binary:   $exe
      signal:   $signal
      time:     $when

    Use the diagnose-crash skill at ${skill}. Establish the facts from the
    core dump and report evidence separately from inference. Do not modify the
    system. Delete any temporary core dump after inspection.
    PROMPT
    )

    export PATH="${runtimePath}:$PATH"
    exec ${pkgs.llm-agents.codex}/bin/codex --dangerously-bypass-approvals-and-sandbox "$prompt"
  '';

  crash-watch = pkgs.writeShellScriptBin "ai-crash-watch" ''
    set -uo pipefail

    readonly message_id=fc2e22bc6ee647b6b90729ab34a250b1
    readonly dedupe_seconds=''${AI_CRASH_DEDUPE_SECONDS:-60}
    declare -A last_notified

    announce() {
      local comm=$1 pid=$2 exe=$3 signal=$4 action
      action=$(${pkgs.libnotify}/bin/notify-send --urgency=critical --wait \
        --action=diagnose="Diagnose with AI" \
        "Process crashed: $comm" "Click to diagnose with AI") || return 1
      [[ $action == diagnose ]] || return 0
      ${pkgs.unstable.ghostty}/bin/ghostty -e ${diagnose-crash}/bin/diagnose-crash "$pid" "$comm" "$exe" "$signal" &
    }

    journalctl -f -n 0 -o json "MESSAGE_ID=$message_id" |
      while IFS= read -r entry; do
        IFS=$'\t' read -r uid comm pid exe signal < <(
          ${pkgs.jq}/bin/jq -r '[(._UID // "-"), (.COREDUMP_COMM // "-"),
            (.COREDUMP_PID // "-"), (.COREDUMP_EXE // "-"),
            (.COREDUMP_SIGNAL_NAME // "-")] | @tsv' <<<"$entry" 2>/dev/null
        )

        [[ $pid =~ ^[0-9]+$ && $uid == "$UID" ]] || continue
        [[ $exe == /* ]] && name=''${exe##*/} || name=$comm
        [[ $name == ai-crash-* || $name == diagnose-crash ]] && continue
        now=$EPOCHSECONDS
        (((now - ''${last_notified[$name]:-0}) < dedupe_seconds)) && continue
        announce "$name" "$pid" "$exe" "$signal" && last_notified[$name]=$now
      done
  '';

  toggle-crash-capture = pkgs.writeShellScriptBin "toggle-crash-capture" ''
    set -euo pipefail
    state=${stateDir}/capture-off
    if [[ -e "$state" ]]; then
      rm "$state"
      systemctl --user start ai-crash-watch.service
      ${pkgs.libnotify}/bin/notify-send "Crash capture enabled"
    else
      mkdir -p "$(dirname "$state")"
      : > "$state"
      systemctl --user stop ai-crash-watch.service
      ${pkgs.libnotify}/bin/notify-send "Crash capture disabled"
    fi
  '';
in {
  options.modules.ai.crash = {
    enable = lib.mkEnableOption "AI crash diagnosis notifications";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [diagnose-crash toggle-crash-capture];

    systemd.user.services.ai-crash-watch = {
      Unit = {
        Description = "Announce process crashes and offer an AI diagnosis";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
        ConditionEnvironment = "WAYLAND_DISPLAY";
        ConditionPathExists = "!${stateDir}/capture-off";
      };
      Service = {
        ExecStart = "${crash-watch}/bin/ai-crash-watch";
        Restart = "always";
        RestartSec = 5;
      };
      Install.WantedBy = ["graphical-session.target"];
    };

    modules.ai.skills.diagnose-crash = skill;
  };
}
