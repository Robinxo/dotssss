#!/usr/bin/env sh
# bulletproof dwm-style status for Waybar
# - ignores any incoming positional args
# - always prints {"output":"..."} (matches your current config)
# - logs internal errors to ~/.cache/waybar/dwm_status.log

LOG="$HOME/.cache/waybar/dwm_status.log"
mkdir -p "$(dirname "$LOG")"

# Drop any positional arguments Waybar might have passed
set --

# helpers (silent on errors)
_load() {
  awk '{printf "%.2f", $1}' /proc/loadavg 2>/dev/null || printf "?"
}

_battery() {
  if command -v upower >/dev/null 2>&1; then
    dev=$(upower -e 2>/dev/null | grep -i battery | head -n1)
    if [ -n "$dev" ]; then
      pct=$(upower -i "$dev" 2>/dev/null | awk '/percentage/ {gsub("%",""); print $2; exit}')
      [ -n "$pct" ] && {
        printf "%s%%" "$pct"
        return 0
      }
    fi
  fi

  for d in /sys/class/power_supply/BAT*; do
    [ -d "$d" ] || continue
    if [ -f "$d/capacity" ]; then
      cat "$d/capacity" 2>/dev/null && printf "%%"
      return 0
    fi
  done

  return 1
}

_volume() {
  if command -v pactl >/dev/null 2>&1; then
    out=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | head -n1)
    vol=$(printf '%s' "$out" | awk '{ for(i=1;i<=NF;i++) if ($i ~ /%/) { gsub(/[^0-9]/,"",$i); print $i; exit } }')
    [ -n "$vol" ] && {
      printf "%s%%" "$vol"
      return 0
    }
  fi
  return 1
}

_date() { date '+%a %d %b %H:%M' 2>/dev/null || date 2>/dev/null; }

# Collect values (safely)
LOAD=$(_load 2>>"$LOG")
BAT=$(_battery 2>>"$LOG") || BAT=""
VOL=$(_volume 2>>"$LOG") || VOL=""
DATE=$(_date 2>>"$LOG")

# Compose status (dwm style)
STATUS="${LOAD}"
[ -n "$VOL" ] && STATUS="${STATUS} | VOL ${VOL}"
[ -n "$BAT" ] && STATUS="${STATUS} | BAT ${BAT}"
STATUS="${STATUS} | ${DATE}"

# escape backslashes and quotes
escaped=$(printf '%s' "$STATUS" | sed 's/\\/\\\\/g; s/"/\\"/g')

# output JSON with "output" key (matches your printed JSON)
printf '{"output":"%s"}\n' "$escaped"
