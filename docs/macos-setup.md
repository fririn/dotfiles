# macOS Setup Guide

Replicating the Arch Linux + Hyprland workflow on macOS.

| Linux | macOS |
|---|---|
| Hyprland | AeroSpace |
| Waybar | SketchyBar |
| Kitty | Ghostty |
| tmux | tmux (unchanged) |
| rofi | Raycast |
| pacman | Homebrew |

---

## 1. Install dependencies

```bash
brew install \
  aerospace \
  sketchybar \
  ghostty \
  tmux \
  neovim \
  lsd \
  yazi \
  fzf \
  fd \
  ripgrep \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  oh-my-zsh   # or: sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Nerd Font (same as Linux)
brew install --cask font-fantasque-sans-mono-nerd-font
```

---

## 2. Stow dotfiles

```bash
cd ~/.dotfiles
stow home          # symlinks everything under home/ into ~
```

This places:
- `~/.config/aerospace/aerospace.toml`
- `~/.config/sketchybar/`
- `~/.config/ghostty/config`
- `~/.tmux.conf`
- `~/.zshrc`
- `~/.shell_aliases`

---

## 3. AeroSpace (Hyprland replacement)

AeroSpace is a tiling WM that works without disabling SIP.
It uses **workspaces** just like Hyprland.

### Why AeroSpace over yabai
- No SIP disable required
- Workspace-first model identical to Hyprland/i3
- Simpler config, more stable

### Modifier mapping

| Hyprland | macOS |
|---|---|
| `Super` (mod key) | `cmd` |
| `Alt` / `Meta` | `option` (left for tmux) |

`cmd` is used for all WM operations so `option` stays completely free for tmux.

### Key bindings

| Action | macOS | Linux equiv |
|---|---|---|
| Focus left/down/up/right | `cmd+h/j/k/l` | `super+h/j/k/l` |
| Move window | `cmd+shift+h/j/k/l` | `super+ctrl+arrow` |
| Resize | `cmd+alt+h/j/k/l` | `binde super, resize` |
| Workspace 1-10 | `cmd+1-0` | `super+1-0` |
| Move to workspace | `cmd+shift+1-0` | `super+shift+1-0` |
| Next/prev workspace | `cmd+./,` | `super+period/comma` |
| Open terminal | `cmd+return` | `super+return` |
| Fullscreen | `cmd+m` | `super+m` |
| Float toggle | `cmd+f` | `super+f` |
| Close window | `cmd+w` | `super+c` |
| Reload config | `cmd+shift+r` | `super+r` |

### Monitor assignment
Workspaces 1-10 → main display
Workspaces 11-12 → secondary display (falls back to main if absent)

### macOS system settings to tweak
Disable the default cmd+h "hide window" system shortcut so AeroSpace can own it:

> System Settings → Keyboard → Keyboard Shortcuts → App Shortcuts
> Add a global shortcut mapping `cmd+h` to something unused (or just accept AeroSpace will intercept it)

Alternatively, AeroSpace intercepts it first anyway once configured — no action required.

---

## 4. SketchyBar (Waybar replacement)

```bash
brew services start sketchybar
```

Shows: AeroSpace workspace indicators · Active app name · Clock · Battery · WiFi

The config lives at `~/.config/sketchybar/sketchybarrc`.
Plugins are in `~/.config/sketchybar/plugins/`.

---

## 5. Ghostty — critical macOS setting

The single most important line in `~/.config/ghostty/config`:

```
macos-option-as-alt = true
```

Without this, `Option+h` sends the Unicode character `ˆ` instead of the
escape sequence `ESC h`, so **all tmux Meta binds break** (`M-h/j/k/l` pane
navigation, `M-m` zoom, `M-H/J/K/L` resize).

All Ghostty default keybinds are cleared (`keybind = clear`) so nothing
intercepts tmux sequences. Only `cmd+c/v/q/m` and the quick terminal toggle
are re-added.

### Quick terminal (scratchpad/F12 equivalent)
`cmd+`` ` (backtick) toggles a Ghostty dropdown terminal from anywhere —
equivalent to `F12 → togglespecialworkspace, terminal` in Hyprland.

---

## 6. tmux — no changes needed

The existing config works on macOS without modification.
macOS tmux (2.6+) handles `pbcopy`/`pbpaste` natively.

### Keybind reminder

| Action | Bind | Note |
|---|---|---|
| Navigate panes | `opt+h/j/k/l` | requires `macos-option-as-alt = true` |
| Resize panes | `opt+H/J/K/L` | shift variants |
| Zoom pane | `opt+m` | |
| New window | `ctrl+t` | |
| Prev/next window | `ctrl+opt+h/l` | |
| Split horizontal | `ctrl+opt+k` | |
| Split vertical | `ctrl+opt+j` | |
| Rotate panes | `ctrl+opt+o` | |

---

## 7. macOS system tweaks

These one-time settings help avoid conflicts and improve the feel:

```bash
# Disable press-and-hold key repeat (enables key repeat for vim/tmux)
defaults write -g ApplePressAndHoldEnabled -bool false

# Fast key repeat (important for vim inside tmux)
defaults write -g KeyRepeat -int 1
defaults write -g InitialKeyRepeat -int 15

# Disable auto-correct / smart quotes (breaks terminal input)
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false

# Show hidden files in Finder
defaults write com.apple.finder AppleShowAllFiles YES && killall Finder

# Disable Spotlight on cmd+space if using Raycast instead
# (do this via System Settings → Keyboard Shortcuts → Spotlight)
```

After running these, **log out and back in** for key repeat to take effect.

---

## 8. Raycast (rofi replacement)

Install from https://raycast.com — set it to `cmd+space`.
Replaces: rofi launcher, clipboard history, emoji picker, ssh menu.

---

## 9. Disable macOS shortcuts that conflict

In **System Settings → Keyboard → Keyboard Shortcuts**:

| Default shortcut | Conflicts with | Action |
|---|---|---|
| `cmd+h` → Hide Window | AeroSpace focus-left | AeroSpace intercepts — no action needed |
| `cmd+m` → Minimise | AeroSpace fullscreen | Disable in Mission Control shortcuts |
| `ctrl+arrow` → Mission Control spaces | AeroSpace (none, uses cmd) | No conflict |

---

## 10. Autostart

```bash
# AeroSpace — configure start-at-login = true in aerospace.toml (already set)

# SketchyBar
brew services start sketchybar

# Ghostty opens on login automatically once it's in Login Items
# System Settings → General → Login Items → add Ghostty
```
