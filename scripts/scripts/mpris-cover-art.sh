#!/bin/bash

# Get active player
player=$(playerctl -l 2>/dev/null | grep -m1 .)
[ -z "$player" ] && exit 0

# Get art URL (may be remote)
art_url=$(playerctl --player="$player" metadata mpris:artUrl 2>/dev/null)

# Exit if nothing returned
[ -z "$art_url" ] && exit 1

# If local file
if [[ "$art_url" =~ ^file:// ]]; then
  file_path="${art_url#file://}"
  [ -f "$file_path" ] && ln -sf "$file_path" /tmp/cover.png && exit 0
fi

# If it's a remote HTTP(S) URL (Spotify)
if [[ "$art_url" =~ ^https?:// ]]; then
  curl -sL "$art_url" -o /tmp/cover.png
  exit 0
fi

# Fallback default
cp ~/.config/waybar/default-cover.png /tmp/cover.png
