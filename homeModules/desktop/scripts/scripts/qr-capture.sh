#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: qr-capture

Select a screen region, decode one QR code, and copy its value to the
clipboard as sensitive content. The QR value is never printed or included in
notifications.
EOF
}

notify() {
  notify-send --app-name="Capture toolbox" "$1" "$2"
}

case "${1:-}" in
"") ;;
-h | --help)
  show_help
  exit 0
  ;;
*)
  show_help >&2
  exit 2
  ;;
esac

temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/qr-capture.XXXXXX")"
image="$temp_dir/capture.png"
payload="$temp_dir/payload"
trap 'rm -rf -- "$temp_dir"' EXIT HUP INT TERM

if ! dms screenshot region \
  --dir "$temp_dir" \
  --filename "capture.png" \
  --no-notify \
  --no-clipboard \
  --cursor off >/dev/null 2>&1; then
  notify "QR capture failed" "No screen region was captured."
  exit 1
fi

if [[ ! -s $image ]]; then
  notify "QR capture failed" "No screen region was captured."
  exit 1
fi

if ! zbarimg \
  --quiet \
  --raw \
  --oneshot \
  --set '*.enable=0' \
  --set 'qrcode.enable=1' \
  "$image" >"$payload" 2>/dev/null; then
  notify "QR code not found" "Try selecting the code more closely."
  exit 1
fi

if [[ ! -s $payload ]]; then
  notify "QR code not found" "The selected QR code had no readable value."
  exit 1
fi

# zbarimg terminates each decoded value with one newline. Remove only that
# delimiter, preserving any newline that is part of the QR payload itself.
truncate --size=-1 "$payload"
wl-copy --sensitive <"$payload"
notify "QR code copied" "The decoded value was copied as sensitive content."
