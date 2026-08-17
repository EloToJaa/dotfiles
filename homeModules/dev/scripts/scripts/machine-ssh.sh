#!/usr/bin/env bash

set -euo pipefail

machines=(
  "laptop elotoja@100.84.67.19"
  "thinker elotoja@100.114.61.57"
  "desktop elotoja@100.112.233.120"
  "server elotoja@100.120.221.4"
  "miro elotoja@100.97.22.118"
)

list_machines() {
  printf '%s\n' "${machines[@]}"
}

select_machine_fzf() {
  list_machines | fzf --prompt="Select machine> " --with-nth=1
}

select_machine_vicinae() {
  list_machines | vicinae dmenu --placeholder "Select machine"
}

ssh_target_for_machine() {
  local machine="$1"
  local entry name target

  for entry in "${machines[@]}"; do
    read -r name target <<<"$entry"
    [ "$name" = "$machine" ] || continue
    printf '%s\n' "$target"
    return 0
  done

  return 1
}

ssh_target_for_selection() {
  local selection="$1"
  local name target

  read -r name target <<<"$selection"
  if [ -n "${target:-}" ]; then
    printf '%s\n' "$target"
    return 0
  fi

  if target="$(ssh_target_for_machine "$name")"; then
    printf '%s\n' "$target"
    return 0
  fi

  printf 'machine-ssh: unknown machine: %s\n' "$name" >&2
  return 1
}

connect_selected_machine() {
  local target

  [ -n "$1" ] || exit 0
  target="$(ssh_target_for_selection "$1")"
  exec ssh "$target"
}

open_selected_machine() {
  local target

  [ -n "$1" ] || exit 0
  target="$(ssh_target_for_selection "$1")"
  exec ghostty +new-window -e ssh "$target"
}

print_usage() {
  printf 'Usage: machine-ssh [--terminal|--desktop|--list|MACHINE]\n'
}

case "${1:---terminal}" in
--terminal)
  selected="$(select_machine_fzf)" || exit 0
  connect_selected_machine "$selected"
  ;;
--desktop)
  selected="$(select_machine_vicinae)" || exit 0
  open_selected_machine "$selected"
  ;;
--list)
  list_machines
  ;;
-h | --help)
  print_usage
  ;;
--*)
  printf 'machine-ssh: unknown option: %s\n' "$1" >&2
  print_usage >&2
  exit 64
  ;;
*)
  connect_selected_machine "$1"
  ;;
esac
