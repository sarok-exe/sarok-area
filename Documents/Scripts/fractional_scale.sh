#!/bin/bash
# Fractional scaling for niri

ACTION="${1:-toggle}"

get_output() {
    niri msg outputs | head -1 | sed 's/Output "//' | sed 's/"//' | sed 's/ (.*//'
}

get_scale() {
    niri msg outputs | grep "Scale:" | awk '{print $2}'
}

OUTPUT=$(get_output)

case "$ACTION" in
    in)
        current=$(get_scale)
        new_scale=$(echo "$current + 0.1" | bc)
        niri msg output "$OUTPUT" scale "$new_scale"
        notify-send "Scale" "Set to ${new_scale}x" -t 1500
        ;;
    out)
        current=$(get_scale)
        new_scale=$(echo "$current - 0.1" | bc)
        if (( $(echo "$new_scale < 0.5" | bc -l) )); then
            new_scale=0.5
        fi
        niri msg output "$OUTPUT" scale "$new_scale"
        notify-send "Scale" "Set to ${new_scale}x" -t 1500
        ;;
    reset)
        niri msg output "$OUTPUT" scale 1.0
        notify-send "Scale" "Reset to 1.0x" -t 1500
        ;;
    show)
        current=$(get_scale)
        notify-send "Scale" "Current: ${current}x" -t 1500
        ;;
    *)
        echo "Usage: $0 {in|out|reset|show}"
        ;;
esac