#!/bin/bash
# Run as the regular user (not root); sudo is invoked where root is needed.
#
# Desktop selection:
#   ./void.sh              -> sway + i3blocks (default)
#   DESKTOP=niri ./void.sh -> niri + noctalia (built from source)
#   DESKTOP=both ./void.sh -> install both, pick at login

set -euo pipefail

DOTFILES_REPO="https://github.com/fririn/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
DESKTOP="${DESKTOP:-sway}"
TARGET_USER=$(id -un)

case "$DESKTOP" in
    sway|niri|both) ;;
    *) echo "DESKTOP must be one of: sway, niri, both (got '$DESKTOP')" >&2; exit 1 ;;
esac

want_sway() { [ "$DESKTOP" = sway ] || [ "$DESKTOP" = both ]; }
want_niri() { [ "$DESKTOP" = niri ] || [ "$DESKTOP" = both ]; }

log() { printf '\n=== %s ===\n' "$*"; }

# ---------------------------------------------------------------------------
# 1. Repos + package manager bootstrap
#
# multilib/multilib-nonfree are needed for steam (32-bit deps); without them
# the steam install below fails and, under `set -e`, kills the whole run.
# ---------------------------------------------------------------------------
log "Enabling nonfree + multilib repos, updating xbps and the system"
sudo xbps-install -Sy void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree

# Voiders community repo: carries noctalia (v5) and zen-browser, neither of
# which is in the official repos. Adding it means trusting its signing key,
# which "-Sy" imports without prompting -- the key is "Voiders Community",
# md5 09:51:93:6c:f9:a0:86:30:e4:89:e7:b0:bb:ca:f1:9c.
log "Enabling the Voiders community repo"
echo "repository=https://repo.voiders.dev" \
    | sudo tee /etc/xbps.d/10-voiders-community.conf >/dev/null

sudo xbps-install -Suy xbps
sudo xbps-install -Suy

# ---------------------------------------------------------------------------
# 2. Locale (adjust if you're not on en_US.UTF-8)
# ---------------------------------------------------------------------------
log "Enabling en_US.UTF-8 locale"
sudo sed -i 's/^#\(en_US\.UTF-8 UTF-8\)/\1/' /etc/default/libc-locales
sudo xbps-reconfigure -f glibc-locales

# ---------------------------------------------------------------------------
# 3. Packages (compositor-independent)
# ---------------------------------------------------------------------------
log "Installing packages"
sudo xbps-install -Sy \
    mesa mesa-dri \
    dejavu-fonts-ttf xorg-fonts nerd-fonts \
    elogind dbus wayland polkit \
    xdg-desktop-portal xdg-desktop-portal-gtk \
    qt5-wayland qt6-wayland \
    foot foot-terminfo ncurses-term fuzzel rofi dmenu \
    brightnessctl grim slurp wl-clipboard cliphist flameshot mako libnotify jq \
    tlp iwd \
    pipewire wireplumber wireplumber-elogind sof-firmware \
    zsh tmux yazi fastfetch neovim git rsync curl unzip gcc psmisc zstd \
    kitty acpi lm_sensors playerctl perl iw ethtool \
    alsa-utils bc \
    htop ncdu xtools kubectl k9s postgresql-client \
    firefox qutebrowser telegram-desktop steam anki zen-browser \
    nodejs tailscale ripgrep fzf

# ---------------------------------------------------------------------------
# 3b. CPU/GPU vendor packages -- detected, so this stays portable across
#     Intel and AMD hosts.
# ---------------------------------------------------------------------------
is_intel_cpu() {
    grep -q '^vendor_id[[:space:]]*:[[:space:]]*GenuineIntel' /proc/cpuinfo
}
is_amd_cpu() {
    grep -q '^vendor_id[[:space:]]*:[[:space:]]*AuthenticAMD' /proc/cpuinfo
}
# $1 = PCI vendor id, e.g. 0x8086 (Intel), 0x1002 (AMD/ATI)
has_gpu_from() {
    local class vendor
    for dev in /sys/bus/pci/devices/*/; do
        class=$(cat "${dev}class" 2>/dev/null)
        vendor=$(cat "${dev}vendor" 2>/dev/null)
        [ "${class#0x03}" != "$class" ] && [ "$vendor" = "$1" ] && return 0
    done
    return 1
}

if is_intel_cpu; then
    log "Intel CPU detected, installing intel-ucode"
    sudo xbps-install -Sy intel-ucode
fi

if has_gpu_from 0x8086; then
    log "Intel GPU detected, installing mesa-vulkan-intel, linux-firmware-intel, intel-video-accel"
    sudo xbps-install -Sy mesa-vulkan-intel linux-firmware-intel intel-video-accel
fi

# linux-firmware-amd carries both the AMD CPU microcode (there is no separate
# amd-ucode package on Void) and the amdgpu/ACP blobs. base-system does *not*
# pull it in, and on recent APUs -- Strix Halo / Ryzen AI in particular -- the
# GPU and the onboard audio simply don't come up without it.
if is_amd_cpu || has_gpu_from 0x1002; then
    log "AMD detected, installing linux-firmware-amd + radeon userspace"
    sudo xbps-install -Sy linux-firmware-amd mesa-ati-dri mesa-vulkan-radeon mesa-vaapi
    # Force an initramfs rebuild so the microcode is early-loaded on next boot.
    sudo xbps-reconfigure -f "linux$(uname -r | grep -oE '^[0-9]+\.[0-9]+')" || true
fi

# ---------------------------------------------------------------------------
# 3c. Compositor + shell
# ---------------------------------------------------------------------------
if want_sway; then
    log "Installing sway + i3blocks"
    # swayidle/swaylock are exec'd directly from home/config/sway/config.
    sudo xbps-install -Sy sway swayidle swaylock i3blocks i3blocks-blocklets \
        xdg-desktop-portal-wlr
fi

if want_niri; then
    log "Installing niri"
    # niri can't use xdg-desktop-portal-wlr; the gnome portal is what upstream
    # recommends for screencast/screenshare. xwayland-satellite is what gets
    # X11-only apps (rofi, dmenu, flameshot) onto the screen.
    sudo xbps-install -Sy niri xwayland-satellite xdg-desktop-portal-gnome

    # Noctalia v5 (the C++ rewrite) comes from the Voiders community repo
    # enabled in step 1.
    #
    # Note the package is "noctalia" (v5, C++), NOT "noctalia-shell" -- that
    # name is the older 4.x Quickshell build, which is a different program
    # and reads a different config format.
    #
    # Optional runtime extras, not pulled in by the package: upower for the
    # battery widget, ddcutil for external-monitor brightness, gnome-keyring
    # as the Secret Service provider Noctalia persists credentials in.
    log "Installing noctalia"
    sudo xbps-install -Sy noctalia upower ddcutil gnome-keyring
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
# Guarded: a minimal install may not have acpid at all, and an unguarded
# touch on a missing /etc/sv/acpid aborts the whole script under `set -e`.
[ -d /etc/sv/acpid ] && sudo touch /etc/sv/acpid/down
disable_service wpa_supplicant

# ---------------------------------------------------------------------------
# 5. Shell
# ---------------------------------------------------------------------------
log "Setting zsh as the default shell"
# via sudo so this doesn't stop for a password prompt halfway through the run
sudo chsh -s /usr/bin/zsh "$TARGET_USER"

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
    if [ ! -e "$1" ]; then
        printf 'skip: %s is not in the repo\n' "$1"
        return 0
    fi
    if [ -e "$2" ] || [ -L "$2" ]; then
        printf 'skip: %s already exists\n' "$2"
        return 0
    fi
    ln -s "$1" "$2"
}

for f in .zshrc .zshenv .shell_aliases .tmux.conf .vimrc .gitconfig; do
    link "$DOTFILES_DIR/home/$f" "$HOME/$f"
done

mkdir -p "$HOME/.config"
for app in foot kitty rofi yazi nvim mpv k9s cliphist flameshot fastfetch qutebrowser mako wireplumber; do
    link "$DOTFILES_DIR/home/config/$app" "$HOME/.config/$app"
done

if want_sway; then
    for app in sway swaylock i3blocks; do
        link "$DOTFILES_DIR/home/config/$app" "$HOME/.config/$app"
    done
fi

if want_niri; then
    link "$DOTFILES_DIR/home/config/niri" "$HOME/.config/niri"
    # noctalia5/ holds the v5 TOML config; noctalia/ is the old v3 JSON one.
    # v5 reads ~/.config/noctalia/settings.toml, so the v5 dir is what gets
    # linked into place.
    link "$DOTFILES_DIR/home/config/noctalia5" "$HOME/.config/noctalia"
fi

# ---------------------------------------------------------------------------
# 7. TLP battery care config (overwrites the package default)
# ---------------------------------------------------------------------------
log "Installing TLP battery care config"
sudo install -m 0644 -o root -g root "$DOTFILES_DIR/setup/tlp.conf" /etc/tlp.conf
# tlp was already started above with the packaged config, so reload it.
sudo sv restart tlp >/dev/null 2>&1 || true

log "Installing passwordless sudo rule for TLP profile switching (i3blocks)"
TLP_SUDOERS=$(mktemp)
sed "s/^paul /$TARGET_USER /" "$DOTFILES_DIR/setup/tlp-sudoers" > "$TLP_SUDOERS"
sudo visudo -cf "$TLP_SUDOERS"
# "zz-" prefix: /etc/sudoers.d/wheel grants a blanket ALL=(ALL) ALL that
# requires a password. Sudoers files are read in lexical order and the last
# match wins, so this file must sort after "wheel" or its NOPASSWD rule
# gets overridden.
sudo install -m 0440 -o root -g root "$TLP_SUDOERS" /etc/sudoers.d/zz-tlp-i3blocks
rm -f "$TLP_SUDOERS"

# ---------------------------------------------------------------------------
# 8. Claude Code CLI
# ---------------------------------------------------------------------------
log "Installing Claude Code"
curl -fsSL https://claude.ai/install.sh | bash

# ---------------------------------------------------------------------------
# 9. Tailscale -- interactive, and the only blocking step in the script.
# ---------------------------------------------------------------------------
log "Bringing up tailscale"
cat <<EOF
Authenticate by scanning the QR code below, or by opening the printed URL on
another device. Nothing else depends on this step, so Ctrl-C is safe -- finish
it later with:

    sudo tailscale up --qr
    sudo tailscale set --operator=$TARGET_USER

EOF
# --qr so a headless TTY isn't stuck retyping a login URL by hand.
sudo tailscale up --qr
sudo tailscale set --operator="$TARGET_USER"

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
