#!/usr/bin/env bash

file_name="ocr-screenshot-$(
  LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6
  echo
).png"
dir_name="/tmp/"
temp_image="$dir_name$file_name"

# Capture screen area
dms screenshot region --dir "$dir_name" --filename "$file_name" --no-notify --no-clipboard --cursor off

# Perform OCR and copy to clipboard
tesseract "$temp_image" stdout 2>/dev/null | wl-copy

# Clean up temporary file
rm -f "$temp_image"
