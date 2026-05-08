#!/bin/bash
# OCR Selection - select area and copy text to clipboard

region=$(slurp) || exit 0
[[ -n "$region" ]] || exit 0

if ! grim -g "$region" - | tesseract stdin stdout -l eng 2>/dev/null | wl-copy; then
    echo "OCR failed."
    exit 1
fi

notify-send "OCR" "Text copied to clipboard" -t 2000