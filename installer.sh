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
  sudo pacman -S paru
  popd
else
  info "paru is already installed."
fi
info "Checking cachy-os mirrors"
sudo cachyos-rate-mirrors

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
  vesktop
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
  ttf-jetbrains-mono-nerd
  network-manager-applet
  anki-bin
  ani-cli
  adobe-source-han-sans-jp-fonts
  adobe-source-han-serif-jp-fonts
  cachyos-gaming-meta
  feh
)

info "Installing packages: ${PACKAGES[*]}"
paru -S --needed --noconfirm "${PACKAGES[@]}"

info "setting up bun"
curl -fsSL https://bun.sh/install | bash

info "Refreshing font cache..."
fc-cache -fv
rm -rf ~/.config/fish
rm -rf ~/.config/kitty
# Stow all subdirectories from current dir
STOW_TARGETS=(hypr fish waybar rofi swaync nvim scripts lazygit bash wallpapers ghostty matugen kitty)

info "Stowing config folders from $(pwd)..."
for dir in "${STOW_TARGETS[@]}"; do
  if [ -d "$dir" ]; then
    info "Stowing $dir..."
    stow "$dir"
  else
    info "Skipping $dir (not found)"
  fi
done
info "wallpaperising"
wal -i 'Pictures/wallpapers/aesthetics\ wallpaper/SundarOrat.jpg'

info "✅ All done. System is set up and dotfiles are applied!"
