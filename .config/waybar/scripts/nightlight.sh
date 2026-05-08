#!/usr/bin/env bash
STATE_FILE="/tmp/waybar-nightlight"

toggle() {
  if [ -f "$STATE_FILE" ]; then
    pkill wlsunset
    rm "$STATE_FILE"
  else
    wlsunset -t 3500 -T 3501 &
    touch "$STATE_FILE"
  fi
}

status() {
  if [ -f "$STATE_FILE" ]; then
    echo '{"text": "󰖔", "tooltip": "Night light: ON", "class": "on"}'
  else
    echo '{"text": "󰖨", "tooltip": "Night light: OFF", "class": "off"}'
  fi
}

case "${1:-}" in
  toggle) toggle ;;
  *) status ;;
esac
