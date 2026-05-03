#!/bin/bash
# update system
sudo pacman -Syu

ln -s $0/home/.* ~/
ln -s $0/home/config/alacritty ~/.config/*

# install general utilities
sudo pacman -S --needed base-devel xorg-server xorg-server-utils xorg-xinit vim wget curl git rofi openssh ranger alacritty zsh ueberzug feh mpv flameshot unrar unzip p7zip highlight ffmpegthumbnailer f2fs-tools exfatprogs dosfstools man terminus-font alsa-utils perl-image-exiftool

# install aur helper
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -srci paru
cd ..
rm -rf paru

# install aur packages
paru -S --needed pfetch go-md2man zen-browser emulationstation-de
# change default shell to zsh
chsh -s /usr/bin/zsh

# install oh-my-zsh and plugins themes
curl -L http://install.ohmyz.sh | sh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# install ranger plugins
git clone https://github.com/maximtrp/ranger-archives.git ~/.config/ranger/plugins/ranger-archives
git clone https://github.com/alexanderjeurissen/ranger_devicons ~/.config/ranger/plugins/ranger_devicons


pwd
