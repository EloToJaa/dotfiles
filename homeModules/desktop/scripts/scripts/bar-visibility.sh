#!/usr/bin/env bash

set -euo pipefail

state_file="${XDG_RUNTIME_DIR:-/tmp}/bar-visibility.mode"

set_mode() {
  case "$1" in
  main)
    dms ipc call bar reveal name "Main Bar"
    dms ipc call bar hide name "Bar 2"
    ;;
  privacy)
    dms ipc call bar hide name "Main Bar"
    dms ipc call bar reveal name "Bar 2"
    ;;
  hide)
    dms ipc call bar hide name "Main Bar"
    dms ipc call bar hide name "Bar 2"
    ;;
  esac

  printf '%s\n' "$1" >"$state_file"
}

case "${1:-}" in
main | privacy | hide)
  set_mode "$1"
  ;;
cycle)
  current=hide
  if [[ -r $state_file ]]; then
    IFS= read -r current <"$state_file"
  fi

  case "$current" in
  main) set_mode privacy ;;
  privacy) set_mode hide ;;
  hide | *) set_mode main ;;
  esac
  ;;
*)
  printf 'Usage: %s {main|privacy|hide|cycle}\n' "$0" >&2
  exit 2
  ;;
esac
