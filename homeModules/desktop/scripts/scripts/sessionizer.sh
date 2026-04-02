#!/usr/bin/env bash

dirs=(
  /home/elotoja/Projects
)

ghostty +new-window -e sesh connect "$(
  fd . "${dirs[@]}" --max-depth 1 --type d | vicinae dmenu --placeholder "Select project"
)"
