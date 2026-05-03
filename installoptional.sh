#!/bin/bash
sudo pacman -S --needed telegram-desktop qbittorrent
paru -S --needed dragon-drop discord-canary teams libreoffice

# Install nerd fonts
git clone --depth=1 https://github.com/ryanoasis/nerd-fonts
cd nerd-fonts
./install.sh
cd ..
rm -rf nerd-fonts

git clone https://github.com/Zephirus2/waybar_auto_hide.git
cd waybar_auto_hide/
cargo build --release
mkdir -p ~/.config/hypr/scripts
cp target/release/waybar_auto_hide ~/.config/hypr/scripts/
