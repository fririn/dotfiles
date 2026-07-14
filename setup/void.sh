#!/bin/bash
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
    mesa mesa-dri \
    dejavu-fonts-ttf xorg-fonts nerd-fonts \
    elogind dbus wayland polkit \
    xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
    qt5-wayland qt6-wayland \
    sway foot foot-terminfo ncurses-term fuzzel rofi dmenu \
    brightnessctl grim slurp wl-clipboard cliphist flameshot mako libnotify jq \
    tlp iwd \
    pipewire wireplumber wireplumber-elogind sof-firmware \
    zsh tmux yazi fastfetch neovim git rsync curl unzip gcc psmisc zstd \
    kitty i3blocks i3blocks-blocklets acpi lm_sensors playerctl perl iw ethtool \
    alsa-utils bc \
    htop ncdu xtools kubectl k9s postgresql-client \
    firefox qutebrowser telegram-desktop steam \
    nodejs tailscale ripgrep fzf

# Intel-specific microcode/firmware/GPU packages -- detected and installed
# only on hosts that actually have Intel silicon, so this stays portable to
# AMD/other CPUs and GPUs.
is_intel_cpu() {
    grep -q '^vendor_id[[:space:]]*:[[:space:]]*GenuineIntel' /proc/cpuinfo
}
is_intel_gpu() {
    local class vendor
    for dev in /sys/bus/pci/devices/*/; do
        class=$(cat "${dev}class" 2>/dev/null)
        vendor=$(cat "${dev}vendor" 2>/dev/null)
        [ "${class#0x03}" != "$class" ] && [ "$vendor" = "0x8086" ] && return 0
    done
    return 1
}

if is_intel_cpu; then
    log "Intel CPU detected, installing intel-ucode"
    sudo xbps-install -Sy intel-ucode
fi

if is_intel_gpu; then
    log "Intel GPU detected, installing mesa-vulkan-intel, linux-firmware-intel, intel-video-accel"
    sudo xbps-install -Sy mesa-vulkan-intel linux-firmware-intel intel-video-accel
fi

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
# Usually already on by default from the Void installer, but enabled
# explicitly here in case this is a minimal/manual base install.
enable_service dhcpcd
enable_service sshd

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
for app in sway i3blocks foot kitty rofi yazi nvim mpv k9s cliphist flameshot fastfetch qutebrowser mako wireplumber; do
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
# 8. zen-browser (not in the Void repos; built locally via xbps-src, using
#    https://github.com/salastro/zen-browser as the srcpkg template)
# ---------------------------------------------------------------------------
log "Building and installing zen-browser via xbps-src"
VOID_PACKAGES_DIR="$HOME/.void_packages"
if [ ! -d "$VOID_PACKAGES_DIR" ]; then
    git clone https://github.com/void-linux/void-packages.git "$VOID_PACKAGES_DIR"
fi
if [ ! -d "$VOID_PACKAGES_DIR/srcpkgs/zen-browser" ]; then
    git clone https://github.com/salastro/zen-browser.git \
        "$VOID_PACKAGES_DIR/srcpkgs/zen-browser"
fi
(
    cd "$VOID_PACKAGES_DIR"
    ./xbps-src binary-bootstrap
    ./xbps-src pkg zen-browser
    sudo xbps-install --repository="$VOID_PACKAGES_DIR/hostdir/binpkgs" -y zen-browser
)

# ---------------------------------------------------------------------------
# 9. Anki (upstream release, not the xbps package -- Void's anki package is
#    orphaned and stuck on 2.1.15, which predates the gui_hooks module most
#    add-ons require. Installed from ankitects' own Linux build instead,
#    which bundles its own Qt/Python and stays current independent of the
#    distro repo.)
# ---------------------------------------------------------------------------
log "Installing Anki from upstream release (replacing xbps package)"
if xbps-query anki >/dev/null 2>&1; then
    sudo xbps-remove -y anki
fi

ANKI_TMPDIR=$(mktemp -d)
ANKI_VERSION=$(curl -fsSL https://api.github.com/repos/ankitects/anki/releases/latest | jq -r .tag_name)
curl -fsSL -o "$ANKI_TMPDIR/anki.tar.zst" \
    "https://github.com/ankitects/anki/releases/download/${ANKI_VERSION}/anki-${ANKI_VERSION}-linux-x86_64.tar.zst"
tar --use-compress-program=unzstd -xf "$ANKI_TMPDIR/anki.tar.zst" -C "$ANKI_TMPDIR"
(cd "$ANKI_TMPDIR"/anki-linux && sudo ./install.sh)
rm -rf "$ANKI_TMPDIR"

# ---------------------------------------------------------------------------
# 10. Claude Code CLI
# ---------------------------------------------------------------------------
log "Installing Claude Code"
curl -fsSL https://claude.ai/install.sh | bash

# ---------------------------------------------------------------------------
# 11. Tailscale (interactive: prints a URL to authenticate)
# ---------------------------------------------------------------------------
log "Bringing up tailscale (follow the printed link to authenticate)"
sudo tailscale up
sudo tailscale set --operator="$USER"

log "Done. Log out/in (or reboot) for the shell and service changes to take effect."

# ---------------------------------------------------------------------------
# Not automated -- do these by hand if you need them:
#
# - Copying ~/.ssh, ~/.oh-my-zsh, ~/.kube, ~/work, ~/development, ~/Pictures,
#   or ~/Documents from another machine via rsync. These depend on a specific
#   reachable host and existing SSH access, so they aren't reproducible from
#   a fresh install.
#
# - pinniped CLI: download the linux-amd64 binary from the pinniped GitHub
#   releases page, chmod +x, and move it to /usr/local/bin/pinniped. Not
#   packaged in the Void repos and the release URL is version-specific, so
#   it's left as a manual step.
# ---------------------------------------------------------------------------
