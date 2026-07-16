#!/usr/bin/env bash

set -euo pipefail

dirs=(
  /home/elotoja/Projects
)

list_projects() {
  fd . "${dirs[@]}" --max-depth 1 --type d
}

select_project_fzf() {
  list_projects | fzf --prompt="Select project> "
}

select_project_vicinae() {
  list_projects | vicinae dmenu --placeholder "Select project"
}

connect_selected_project() {
  [ -n "$1" ] || exit 0
  exec sesh connect "$1"
}

case "${1:---terminal}" in
--terminal)
  selected="$(select_project_fzf)" || exit 0
  connect_selected_project "$selected"
  ;;
--desktop)
  selected="$(select_project_vicinae)" || exit 0
  [ -n "$selected" ] || exit 0
  exec ghostty +new-window -e sesh connect "$selected"
  ;;
-h | --help)
  printf 'Usage: sessionizer [--terminal|--desktop]\n'
  ;;
*)
  printf 'sessionizer: unknown option: %s\n' "$1" >&2
  printf 'Usage: sessionizer [--terminal|--desktop]\n' >&2
  exit 64
  ;;
esac
