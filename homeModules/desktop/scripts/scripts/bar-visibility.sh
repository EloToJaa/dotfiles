#!/usr/bin/env bash

set -euo pipefail

state_file="${XDG_RUNTIME_DIR:-/tmp}/bar-visibility.mode"

# Noctalia runs a single bar, so it has no privacy bar: main shows it and both
# privacy and hide hide it.
set_mode() {
  case "$1" in
  main) noctalia msg bar-show ;;
  privacy | hide) noctalia msg bar-hide ;;
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
  main) set_mode hide ;;
  privacy | hide | *) set_mode main ;;
  esac
  ;;
*)
  printf 'Usage: %s {main|privacy|hide|cycle}\n' "$0" >&2
  exit 2
  ;;
esac
