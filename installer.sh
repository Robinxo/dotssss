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
info "checking the best mirrors"
cachyos-rate-mirrors

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
  apple-fonts
  pokemon-colorscripts-git
  nodejs
  go
  starship
  rofi-emoji
  stow
  stremio-enhanced
  zen-browser
  kitty
  helium-browser-bin
  quickshell
  qbittorrent
  fcitx5
  fcitx5-configtool
  fcitx5-gtk
  fcitx5-qt
  fcitx5-mozc
)

info "Installing packages: ${PACKAGES[*]}"
paru -S --needed --noconfirm "${PACKAGES[@]}"

info "Refreshing font cache..."
fc-cache -fv

# Stow all subdirectories from current dir
STOW_TARGETS=(hypr fish waybar rofi swaync nvim scripts lazygit bash wallpapers ghostty matugen)

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
