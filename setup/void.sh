#!/bin/bash
# Bootstraps a fresh Void Linux install into this machine's current sway/foot
# setup. Reconstructed from ~/.bash_history and ~/.zsh_history.
#
# Run as the regular user (not root); sudo is invoked where root is needed.

set -euo pipefail

DOTFILES_REPO="https://github.com/fririn/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

log() { printf '\n=== %s ===\n' "$*"; }

# ---------------------------------------------------------------------------
# 1. Repos + package manager bootstrap
# ---------------------------------------------------------------------------
log "Enabling nonfree repo, updating xbps and the system"
sudo xbps-install -Sy void-repo-nonfree
sudo xbps-install -Suy xbps
sudo xbps-install -Suy

# ---------------------------------------------------------------------------
# 2. Locale (adjust if you're not on en_US.UTF-8)
# ---------------------------------------------------------------------------
log "Enabling en_US.UTF-8 locale"
sudo sed -i 's/^#\(en_US\.UTF-8 UTF-8\)/\1/' /etc/default/libc-locales
sudo xbps-reconfigure -f glibc-locales

# ---------------------------------------------------------------------------
# 3. Packages
# ---------------------------------------------------------------------------
log "Installing packages"
sudo xbps-install -Sy \
    intel-ucode linux-firmware-intel mesa mesa-dri mesa-vulkan-intel \
    dejavu-fonts-ttf xorg-fonts nerd-fonts \
    elogind dbus wayland polkit xdg-desktop-portal xdg-desktop-portal-wlr \
    sway foot foot-terminfo ncurses-term fuzzel rofi dmenu \
    brightnessctl grim slurp wl-clipboard jq \
    tlp iwd \
    zsh tmux yazi fastfetch neovim git rsync curl unzip gcc psmisc \
    kitty i3blocks i3blocks-blocklets acpi iw ethtool \
    firefox qutebrowser telegram-desktop steam \
    nodejs tailscale

# ---------------------------------------------------------------------------
# 4. Services (runit)
# ---------------------------------------------------------------------------
log "Enabling services"
enable_service() {
    [ -e "/var/service/$1" ] || sudo ln -s "/etc/sv/$1" /var/service/
}
disable_service() {
    sudo sv stop "$1" >/dev/null 2>&1 || true
    sudo rm -f "/var/service/$1"
}

enable_service dbus
enable_service elogind
enable_service tlp
enable_service iwd
enable_service tailscaled

# acpid conflicts with elogind's power/lid handling; iwd replaces
# wpa_supplicant entirely -- both get disabled the same way they were here.
disable_service acpid
sudo touch /etc/sv/acpid/down
disable_service wpa_supplicant

# ---------------------------------------------------------------------------
# 5. Shell
# ---------------------------------------------------------------------------
log "Setting zsh as the default shell"
chsh -s /usr/bin/zsh "$USER"

# ---------------------------------------------------------------------------
# 6. Dotfiles: clone + symlink
# ---------------------------------------------------------------------------
log "Cloning dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

log "Linking dotfiles"
link() {
    # $1 = link target (file/dir inside the repo), $2 = symlink path to create
    [ -e "$2" ] || [ -L "$2" ] || ln -s "$1" "$2"
}

for f in .zshrc .zshenv .shell_aliases .tmux.conf .vimrc .gitconfig; do
    link "$DOTFILES_DIR/home/$f" "$HOME/$f"
done

mkdir -p "$HOME/.config"
for app in sway i3blocks foot kitty rofi yazi nvim mpv k9s cliphist flameshot fastfetch qutebrowser; do
    link "$DOTFILES_DIR/home/config/$app" "$HOME/.config/$app"
done

# ---------------------------------------------------------------------------
# 7. TLP battery care config (overwrites the package default)
# ---------------------------------------------------------------------------
log "Installing TLP battery care config"
sudo install -m 0644 -o root -g root "$DOTFILES_DIR/setup/tlp.conf" /etc/tlp.conf

log "Installing passwordless sudo rule for TLP profile switching (i3blocks)"
sudo visudo -cf "$DOTFILES_DIR/setup/tlp-sudoers"
# "zz-" prefix: /etc/sudoers.d/wheel grants a blanket ALL=(ALL) ALL that
# requires a password. Sudoers files are read in lexical order and the last
# match wins, so this file must sort after "wheel" or its NOPASSWD rule
# gets overridden.
sudo install -m 0440 -o root -g root "$DOTFILES_DIR/setup/tlp-sudoers" /etc/sudoers.d/zz-tlp-i3blocks

# ---------------------------------------------------------------------------
# 8. Claude Code CLI
# ---------------------------------------------------------------------------
log "Installing Claude Code"
curl -fsSL https://claude.ai/install.sh | bash

# ---------------------------------------------------------------------------
# 9. Tailscale (interactive: prints a URL to authenticate)
# ---------------------------------------------------------------------------
log "Bringing up tailscale (follow the printed link to authenticate)"
sudo tailscale up

log "Done. Log out/in (or reboot) for the shell and service changes to take effect."

# ---------------------------------------------------------------------------
# Not automated -- do these by hand if you need them:
#
# - Copying ~/.ssh, ~/.oh-my-zsh, or ~/work from another machine via rsync.
#   These depend on a specific reachable host and existing SSH access, so
#   they aren't reproducible from a fresh install.
#
# - zen-browser: not in the Void repos. It was previously built locally via
#   void-packages/xbps-src using https://github.com/salastro/zen-browser as
#   the srcpkg template:
#     git clone https://github.com/void-linux/void-packages.git
#     mkdir -p void-packages/srcpkgs
#     git clone https://github.com/salastro/zen-browser.git \
#         void-packages/srcpkgs/zen-browser
#     cd void-packages && ./xbps-src pkg zen-browser
#   This wasn't confirmed working (not currently installed on this machine),
#   so it's left as a manual step rather than baked into this script.
# ---------------------------------------------------------------------------
