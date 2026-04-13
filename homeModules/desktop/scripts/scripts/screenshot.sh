#!/usr/bin/env bash

dir="$HOME/Pictures/Screenshots"
time=$(date +'%Y_%m_%d_at_%Hh%Mm%Ss')
file_name="Screenshot_${time}.png"
file="$dir/$file_name"

copy() {
  GRIMBLAST_HIDE_CURSOR=0 grimblast --notify --freeze copy area
}

save() {
  GRIMBLAST_HIDE_CURSOR=0 grimblast --notify --freeze save area "$file"
}

edit() {
  GRIMBLAST_HIDE_CURSOR=0 grimblast --notify --freeze save area "$file"
  satty -f "$file"
}

if [[ ! -d "$dir" ]]; then
  mkdir -p "$dir"
fi

if [[ "$1" == "--copy" ]]; then
  copy
elif [[ "$1" == "--save" ]]; then
  save
elif [[ "$1" == "--edit" ]]; then
  edit
else
  echo -e "Available Options: --copy --save --edit"
fi

exit 0
