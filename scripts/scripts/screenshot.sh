#!/bin/sh

LOG="/tmp/screenshot-debug.log"
echo "=== $(date) ===" >>"$LOG"

# ensure dir
dir="$HOME/Pictures/SS"
mkdir -p "$dir" 2>>"$LOG" || {
  echo "mkdir failed" >>"$LOG"
  exit 1
}

# get geometry from slurp
geom="$(slurp 2>>"$LOG")"
echo "slurp -> '$geom'" >>"$LOG"

# if user cancelled slurp, exit cleanly
if [ -z "$geom" ]; then
  echo "selection cancelled or slurp returned empty" >>"$LOG"
  exit 0
fi

file="$dir/$(date +%s).png"

# capture and save
if grim -g "$geom" "$file" 2>>"$LOG"; then
  echo "grim saved $file" >>"$LOG"
else
  echo "grim failed" >>"$LOG"
  exit 1
fi

# copy to clipboard
if wl-copy <"$file" 2>>"$LOG"; then
  echo "wl-copy OK" >>"$LOG"
else
  echo "wl-copy failed" >>"$LOG"
fi

# optional notification
if command -v notify-send >/dev/null 2>&1; then
  notify-send "Screenshot" "Saved & copied: $file"
fi

echo "done" >>"$LOG"
exit 0
