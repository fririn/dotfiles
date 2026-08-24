ZSH_THEME="crunch"
CASE_SENSITIVE="true"
plugins=(
  git
  colored-man-pages
  zsh-autosuggestions
  zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh
source ~/.shell_aliases
eval `ssh-agent` && ssh-add && clear


# run fastfetch only if new terminal is opened not from ranger
if [[ ! $(ps -p $(ps -p $$ -o ppid=) -o args= | grep -i ranger) ]]; then fastfetch -l small;fi

# ── History ───────────────────────────────────────────────────────────────────
HISTSIZE=500000
SAVEHIST=500000
HIST_STAMPS="%d/%m/%y %T"
setopt appendhistory
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# ── PATH ──────────────────────────────────────────────────────────────────────
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="$PATH:$HOME/go/bin"
export PATH="$PATH:$HOME/.local/bin"

# ── Aliases / tools ───────────────────────────────────────────────────────────
alias y="yazi"
alias ra="yazi"

# sway has no session D-Bus unless something starts one first (no display
# manager / session wrapper in this setup) - without it, swaybar's tray and
# other D-Bus-dependent apps (flameshot, etc.) silently fail to register.
sway() {
  if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    dbus-run-session -- sway "$@"
  else
    command sway "$@"
  fi
}

# Same story for niri. There is no niri-session script on Void: the package is
# built with the systemd/dinit features off, so "--session" is the supported
# way to start from a TTY. It sets XDG_CURRENT_DESKTOP=niri and
# XDG_SESSION_TYPE=wayland and pushes them into the activation environment,
# which is what the gnome/gtk portals and gnome-keyring key off.
#
# Only a bare launch on a TTY gets wrapped. Everything else passes straight
# through to the binary: "niri msg ..." and "niri validate" (also run over SSH,
# where there is no session bus and starting one would be wrong), and a bare
# "niri" inside an existing session, which is upstream's nested dev window.
niri() {
  case "${1-}" in
    ''|--session)
      if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
        dbus-run-session -- niri --session
        return
      fi
      ;;
  esac
  command niri "$@"
}

# fzf with preview (same as Linux)
alias fzf="fzf --style full --preview 'fzf-preview.sh {}' --bind 'focus:transform-header:file --brief {}'"

# ── Google Cloud SDK ──────────────────────────────────────────────────────────
if [ -f "$HOME/dev/google-cloud-sdk/path.zsh.inc" ]; then
  source "$HOME/dev/google-cloud-sdk/path.zsh.inc"
fi
if [ -f "$HOME/dev/google-cloud-sdk/completion.zsh.inc" ]; then
  source "$HOME/dev/google-cloud-sdk/completion.zsh.inc"
fi

# ── Blockchain test curls ──────────────────────────────────────────────────────────

checkrpc_evm() {
    if [ -z "$1" ]; then
        echo "Usage: checkrpc <rpc_url>"
        return 1
    fi

    curl -i --location "$1" \
    --header 'Content-Type: application/json' \
    --data '{
        "jsonrpc": "2.0",
        "method": "eth_getBlockByNumber",
        "params": ["latest", false],
        "id": "gemini-check"
    }'
}
checkrpc_sol() {
    curl -i -s --location "$1" \
    --header 'Content-Type: application/json' \
    --data '{"jsonrpc":"2.0","id":1, "method":"getHealth"}'
}
checkrpc_btc() {
    curl -i -s --location "$1" \
    --header 'Content-Type: application/json' \
    --data '{"jsonrpc":"1.0","id":"check","method":"getblockchaininfo","params":[]}'
}
checkrpc_cosmos() {
    curl -i -s --location "$1" \
    --header 'Content-Type: application/json' \
    --data '{"jsonrpc":"2.0","id":1,"method":"abci_info","params":[]}'
}
checkrpc_near() {
    curl -i -s --location "$1" \
    --header 'Content-Type: application/json' \
    --data '{"jsonrpc":"2.0","id":"dontcare","method":"status","params":[]}'
}
checkrpc_aptos() {
    # Aptos uses a REST path for health
    curl -i -s --location "$1/v1/-/healthy"
}

# ── getblock-io repo sync ──────────────────────────────────────────────────
alias gbpull='zsh ~/work/getblock-sync.sh pull'   # pull all getblock repos
alias gbclone='zsh ~/work/getblock-sync.sh clone' # clone any missing repos
alias gbsync='zsh ~/work/getblock-sync.sh sync'   # clone missing + pull all
