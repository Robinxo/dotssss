#!/bin/bash

set -e

# Function to print status messages
function info {
  echo -e "\e[1;32m[INFO]\e[0m $1"
}

# Ensure base-devel and git are installed
info "Installing base-devel and git..."
sudo pacman -Syu --needed --noconfirm base-devel git

# Install paru if not already installed
if ! command -v paru &>/dev/null; then
  info "paru not found, installing paru..."
  git clone https://aur.archlinux.org/paru.git /tmp/paru
  pushd /tmp/paru
  makepkg -si --noconfirm
  popd
else
  info "paru is already installed."
fi

# List of packages to install via paru
PACKAGES=(
  hyprland
  waybar
  neovim
  swww
  matugen-bin
  python-pywal16
  swaync
  rofi
  cliphist
  ghostty
  slurp
  grim
  jq
  bc
  fish
  lazygit
  discord
  departure-mono-font
  pokemon-colorscripts-git
  nodejs
  go
  starship
  rofi-emoji
  stow
  ani-cli
)

info "Installing packages: ${PACKAGES[*]}"
paru -S --needed --noconfirm "${PACKAGES[@]}"

# Install custom fonts from GitHub
FONT_REPO="https://github.com/xeji01/nothingfont.git"
FONT_DIR="$HOME/.local/share/fonts/nothingfont"

info "Cloning nothingfont repo..."
git clone --depth=1 "$FONT_REPO" /tmp/nothingfont

info "Installing fonts to $FONT_DIR..."
mkdir -p "$FONT_DIR"
find /tmp/nothingfont -type f \( -iname "*.ttf" -o -iname "*.otf" -o -iname "*.woff" -o -iname "*.woff2" \) -exec cp {} "$FONT_DIR" \;

info "Refreshing font cache..."
fc-cache -fv

# Stow all subdirectories from current dir
STOW_TARGETS=(hypr ghostty fish waybar rofi swaync nvim matugen scripts)

info "Stowing config folders from $(pwd)..."
for dir in "${STOW_TARGETS[@]}"; do
  if [ -d "$dir" ]; then
    info "Stowing $dir..."
    stow "$dir"
  else
    info "Skipping $dir (not found)"
  fi
done

info "✅ All done. System is set up and dotfiles are applied!"
