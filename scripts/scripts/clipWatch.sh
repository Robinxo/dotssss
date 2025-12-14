#!/bin/bash
last_clip=$(wl-paste --no-newline 2>/dev/null)

while true; do
  sleep 0.5
  current_clip=$(wl-paste --no-newline 2>/dev/null)

  if [[ "$current_clip" != "$last_clip" && -n "$current_clip" ]]; then
    notify-send "Clipboard Changed" "$current_clip"
    last_clip="$current_clip"
  fi
done
