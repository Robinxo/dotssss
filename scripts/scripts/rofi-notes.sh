#!/usr/bin/env bash

# Set your notes directory
NOTES_DIR="$HOME/Stuff/notes/"

# Check if it's a git repo; init if not
if [ ! -d "$NOTES_DIR/.git" ]; then
  git -C "$NOTES_DIR" init >/dev/null 2>&1
  echo "Initialized empty Git repo in $NOTES_DIR"
fi

# Find markdown notes
NOTE_LIST=$(find "$NOTES_DIR" -type f -name "*.md" | sed "s|$NOTES_DIR/||" | sort)

# Options for Rofi menu
OPTIONS="📝 New Note\n$NOTE_LIST"

# Launch Rofi
SELECTED=$(echo -e "$OPTIONS" | rofi -theme ~/.config/rofi/config1.rasi -dmenu -i -p "Select or Create Note")

# Exit if nothing selected
[ -z "$SELECTED" ] && exit 0

# Handle new note
if [[ "$SELECTED" == "📝 New Note" ]]; then
  NOTE_NAME=$(rofi -dmenu -p "Enter note title" <<<"")
  [ -z "$NOTE_NAME" ] && exit 0
  FILE_NAME="$(echo "$NOTE_NAME" | sed 's/[^a-zA-Z0-9_-]/_/g').md"
  FILE_PATH="$NOTES_DIR/$FILE_NAME"
  touch "$FILE_PATH"
  git -C "$NOTES_DIR" add "$FILE_PATH"
  git -C "$NOTES_DIR" commit -m "Create note: $FILE_NAME" >/dev/null 2>&1
else
  FILE_PATH="$NOTES_DIR/$SELECTED"
fi

# Open with Neovim and start MarkdownPreview if available

exec wezterm start -- nvim +"MarkdownPreview" "$FILE_PATH"
