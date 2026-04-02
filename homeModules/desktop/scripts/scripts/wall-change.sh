#!/usr/bin/env bash

animations=("outer" "center" "any" "wipe")
random_animation=${animations[RANDOM%${#animations[@]}]}
wallpaper_path="$HOME/Pictures/wallpapers"

if [[ "$random_animation" == "wipe" ]]; then
  awww img --transition-type="wipe" --transition-angle=135 "$1" &
else
  awww img --transition-type="$random_animation" "$1" &
fi

ln -sf "$1" "$wallpaper_path/wallpaper"
