#!/bin/sh
# switch-audio: choose Pulse/PipeWire sink via dmenu and optionally move streams
# Usage: switch-audio [--move]    (use --move to move existing sink-inputs)

MOVE_STREAMS=no
if [ "$1" = "--move" ]; then
  MOVE_STREAMS=yes
fi

# required tools
command -v pactl >/dev/null 2>&1 || {
  echo "ERROR: pactl not found"
  exit 2
}
command -v dmenu >/dev/null 2>&1 || {
  echo "ERROR: dmenu not found"
  exit 2
}
command -v jq >/dev/null 2>&1 || JQ_MISSING=yes

# Try JSON output first (preferred)
json="$(pactl -f json list sinks 2>/dev/null)" || json=""
menu=""
if [ -n "$json" ] && [ -z "$JQ_MISSING" ]; then
  # Build menu entries: "index: Description — name"
  menu=$(printf "%s" "$json" | jq -r '.[] | "\(.index): \(.description) — \(.name)"')
fi

# If menu empty, fallback to short listing
if [ -z "$menu" ]; then
  # Fallback: pactl list short sinks (index, name, driver, state)
  short="$(pactl list short sinks 2>/dev/null)" || short=""
  if [ -z "$short" ]; then
    notify-send "switch-audio" "No sinks found (pactl returned nothing)."
    exit 3
  fi

  # Build menu entries with index and name; use pactl info to get descriptions if possible
  menu=""
  while IFS= read -r line; do
    idx=$(printf "%s" "$line" | awk '{print $1}')
    name=$(printf "%s" "$line" | awk '{print $2}')
    # try to get a human friendly description
    desc="$(pactl list sinks 2>/dev/null | awk -v RS= -v idx="$idx" '($0 ~ "Sink #"? idx: ""){ if(match($0,/Description: .*/)) {print substr($0,RSTART+13)} }' | head -n1)"
    [ -z "$desc" ] && desc="$name"
    menu="${menu}${idx}: ${desc} — ${name}\n"
  done <<EOF
$(printf "%s\n" "$short")
EOF
  # remove trailing newline for dmenu
  menu=$(printf "%b" "$menu")
fi

# show dmenu
selection=$(printf "%b" "$menu" | dmenu -i -l 8 -p "Output:")

# user cancelled
[ -z "$selection" ] && exit 0

# extract index/name from selection (formats handled: "index: desc — name" or "index: desc - name")
# get last token after '—' or '-' if present, else last field
sink_name=$(printf "%s" "$selection" | awk -F '—' '{ if (NF>1) {print $NF} else {print $0} }' | awk -F '-' '{ if (NF>1) {print $NF} else {print $0} }' | awk '{print $NF}' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

# sanity: if sink_name looks like "index: ..." get the part after colon's last word
if printf "%s" "$sink_name" | grep -q ':'; then
  sink_name=$(printf "%s" "$sink_name" | awk -F ':' '{print $NF}' | awk '{print $NF}')
fi

# final check: if sink_name empty, try parse index and resolve name via pactl
if [ -z "$sink_name" ]; then
  idx=$(printf "%s" "$selection" | awk -F ':' '{print $1}' | tr -d ' ')
  if [ -n "$idx" ]; then
    sink_name=$(pactl list short sinks | awk -v i="$idx" '$1==i{print $2; exit}')
  fi
fi

if [ -z "$sink_name" ]; then
  notify-send "switch-audio" "Failed to parse sink from selection."
  exit 4
fi

# set default sink
pactl set-default-sink "$sink_name" 2>/dev/null
if [ $? -ne 0 ]; then
  notify-send "switch-audio" "Failed to set default sink: $sink_name"
  exit 5
fi

# optionally move existing streams
if [ "$MOVE_STREAMS" = "yes" ]; then
  pactl list short sink-inputs | awk '{print $1}' | while read -r input; do
    pactl move-sink-input "$input" "$sink_name"
  done
fi

notify-send "Audio switched" "$sink_name"
exit 0

#!/usr/bin/env sh
# switch-audio: choose Pulse/PipeWire sink via dmenu and optionally move streams
# usage: switch-audio [--move]

MOVE_STREAMS=no
if [ "$1" = "--move" ]; then
  MOVE_STREAMS=yes
fi

command -v pactl >/dev/null 2>&1 || {
  echo "pactl not found"
  exit 2
}
command -v dmenu >/dev/null 2>&1 || {
  echo "dmenu not found"
  exit 2
}

# Prefer JSON output if jq exists
command -v jq >/dev/null 2>&1 && JQ=yes || JQ=no

# Build menu listing "INDEX: Description — name"
if [ "$JQ" = yes ]; then
  json="$(pactl -f json list sinks 2>/dev/null)" || json=""
  if [ -n "$json" ]; then
    menu=$(printf "%s" "$json" | jq -r '.[] | "\(.index): \(.description) — \(.name)"')
  fi
fi

# Fallback to short listing if JSON unavailable or empty
if [ -z "$menu" ]; then
  short="$(pactl list short sinks 2>/dev/null)" || short=""
  if [ -z "$short" ]; then
    echo "No sinks found"
    exit 3
  fi

  menu=""
  printf "%s\n" "$short" | while IFS= read -r line; do
    idx=$(printf "%s" "$line" | awk '{print $1}')
    name=$(printf "%s" "$line" | awk '{print $2}')
    # Try to extract Description for this index
    desc=$(pactl list sinks 2>/dev/null | awk -v RS= -v idx="$idx" 'index($0,"Sink #") && match($0,"Sink #"?idx:0) { if(match($0,/Description: .*/)) {print substr($0,RSTART+13)} }' | head -n1)
    [ -z "$desc" ] && desc="$name"
    # Append to menu
    menu="${menu}${idx}: ${desc} — ${name}\n"
  done
  menu=$(printf "%b" "$menu")
fi

selection=$(printf "%b" "$menu" | dmenu -i -l 8 -p "Output:")
[ -z "$selection" ] && exit 0

# Parse leading index (number before colon)
selected_index=$(printf "%s" "$selection" | awk -F: '{print $1}' | tr -d '[:space:]')

# Fallback: if parsing failed, try extract trailing name and map to index
if [ -z "$selected_index" ] || ! printf "%s" "$selected_index" | grep -Eq '^[0-9]+$'; then
  # attempt to get last token (name) and resolve index
  sink_name=$(printf "%s" "$selection" | awk -F '—' '{print $NF}' | awk '{print $NF}' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  selected_index=$(pactl list short sinks | awk -v name="$sink_name" '$2==name{print $1; exit}')
fi

if [ -z "$selected_index" ]; then
  echo "Failed to parse selection"
  exit 4
fi

# Set default sink by index (most reliable)
if ! pactl set-default-sink "$selected_index" >/dev/null 2>&1; then
  # show the error from pactl
  pactl set-default-sink "$selected_index" 2>&1 | sed -n '1,200p'
  exit 5
fi

# Optionally move current sink inputs
if [ "$MOVE_STREAMS" = "yes" ]; then
  pactl list short sink-inputs | awk '{print $1}' | while read -r in; do
    pactl move-sink-input "$in" "$selected_index" >/dev/null 2>&1 || true
  done
fi

printf "Switched to sink %s\n" "$selection"
exit 0
