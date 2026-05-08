#!/usr/bin/env bash
MIC_ID=55

get_volume() {
  wpctl get-volume "$MIC_ID" | awk '{print $2 * 100}'
}

is_muted() {
  wpctl get-volume "$MIC_ID" | grep -q "MUTED"
}

toggle() {
  wpctl set-mute "$MIC_ID" toggle
}

up() {
  wpctl set-volume "$MIC_ID" 0.05+
}

down() {
  wpctl set-volume "$MIC_ID" 0.05-
}

status() {
  local vol=$(get_volume)
  if is_muted; then
    echo "{\"text\": \" ${vol}%\", \"tooltip\": \"Mic: MUTED (${vol}%)\", \"class\": \"muted\"}"
  else
    echo "{\"text\": \" ${vol}%\", \"tooltip\": \"Mic: ${vol}%\", \"class\": \"on\"}"
  fi
}

case "${1:-}" in
  toggle) toggle ;;
  up) up ;;
  down) down ;;
  *) status ;;
esac
