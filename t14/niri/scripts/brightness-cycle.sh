#!/usr/bin/env bash
set -euo pipefail

state_file="${XDG_RUNTIME_DIR:-/tmp}/niri-extra-dim"

get_percent() {
  brightnessctl -m | awk -F, '{gsub(/%/,"",$4); print int($4)}'
}

enable_night() {
  dms ipc call night temperature 2500 >/dev/null 2>&1 || true
  dms ipc call night enable >/dev/null 2>&1 || true
  touch "$state_file"
}

disable_night() {
  dms ipc call night disable >/dev/null 2>&1 || true
  rm -f "$state_file"
}

up() {
  local p
  p="$(get_percent)"

  if [ "$p" -le 0 ]; then
    enable_night
    brightnessctl --class=backlight set 1% >/dev/null
  elif [ -f "$state_file" ]; then
    disable_night
    brightnessctl --class=backlight set +10% >/dev/null
  else
    brightnessctl --class=backlight set +10% >/dev/null
  fi
}

down() {
  local p t
  p="$(get_percent)"

  if [ "$p" -gt 1 ]; then
    t=$((p - 10))
    [ "$t" -lt 1 ] && t=1
    brightnessctl --class=backlight set "${t}%" >/dev/null
    disable_night
  elif [ -f "$state_file" ]; then
    disable_night
    brightnessctl --class=backlight set 0 >/dev/null
  else
    enable_night
    brightnessctl --class=backlight set 1% >/dev/null
  fi
}

case "${1:-}" in
  up) up ;;
  down) down ;;
  *)
    echo "Usage: $0 {up|down}" >&2
    exit 2
    ;;
esac
