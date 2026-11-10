#!/usr/bin/env bash

# Noctalia runs the OCR itself once a region is picked: it pipes the capture as
# PNG on stdin and skips the command when the selection is cancelled.
exec noctalia msg screenshot-region \
  --no-annotate \
  --no-save-to-file \
  --no-copy-to-clipboard \
  --pipe-to-command \
  --pipe-command 'tesseract stdin stdout 2>/dev/null | wl-copy'
