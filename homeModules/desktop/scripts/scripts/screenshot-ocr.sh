#!/usr/bin/env bash

# Without dms, Noctalia runs the OCR itself once a region is picked: it pipes
# the capture as PNG on stdin and skips the command when selection is cancelled.
if ! command -v dms >/dev/null; then
  exec noctalia msg screenshot-region \
    --no-annotate \
    --no-save-to-file \
    --no-copy-to-clipboard \
    --pipe-to-command \
    --pipe-command 'tesseract stdin stdout 2>/dev/null | wl-copy'
fi

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
