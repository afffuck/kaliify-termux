#!/data/data/com.termux/files/usr/bin/bash
# ==========================================================
#  Kaliify-Termux v1.0
#  Make your Termux look and feel like Kali Linux Zsh
#  Author: Afffuck
#  Telegram: @xthefs
#  License: Apache-2.0
# ==========================================================

set -euo pipefail

# ---------- Helpers ----------
timestamp=$(date +%Y%m%d-%H%M%S)
backup_dir="$HOME/.kaliify-backups/$timestamp"
mkdir -p "$backup_dir"

log() { echo -e "\033[1;32m[+] $*\033[0m"; }
warn() { echo -e "\033[1;33m[!] $*\033[0m"; }

# ---------- Package Installer ----------
install_pkg() {
    for pkg in "$@"; do
        if ! command -v "$pkg" &>/dev/null; then
            log "Installing $pkg..."
            pkg install -y "$pkg" || warn "Package $pkg not found."
        else
            log "$pkg already installed ✓"
        fi
    done
}

# ---------- Step 1: Install dependencies ----------
log "Updating packages..."
pkg update -y && pkg upgrade -y

install_pkg python git curl wget tar unzip neofetch tmux zsh eza fzf fd bat

# Fix aliases if needed
echo > "$HOME/.aliases"
if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    echo "alias bat='batcat'" >> "$HOME/.aliases"
fi
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    echo "alias fd='fdfind'" >> "$HOME/.aliases"
fi

# ---------- Step 2: Remove Termux banner ----------
touch ~/.hushlogin

# ---------- Step 3: Backup old configs ----------
mkdir -p "$HOME/.termux"
for f in .zshrc .bashrc .termux/termux.properties .aliases; do
    [ -f "$HOME/$f" ] && cp "$HOME/$f" "$backup_dir/"
done

# ---------- Step 4: Install Zsh plugins ----------
mkdir -p ~/.zsh-plugins
cd ~/.zsh-plugins

[ ! -d zsh-autosuggestions ] && git clone https://github.com/zsh-users/zsh-autosuggestions.git
[ ! -d zsh-syntax-highlighting ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
[ ! -d zsh-history-substring-search ] && git clone https://github.com/zsh-users/zsh-history-substring-search.git

cd ~

# ---------- Step 5: Configure .zshrc ----------
cat > "$HOME/.zshrc" <<'EOF'
# ====== Kali-like Zsh configuration ======

autoload -U colors && colors
setopt prompt_subst

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory sharehistory histignoredups

# Completion
autoload -U compinit && compinit
zstyle ':completion:*' menu select
bindkey -e

# Plugins
source $HOME/.zsh-plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/.zsh-plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOME/.zsh-plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# Aliases
[ -f ~/.aliases ] && source ~/.aliases
alias ls='eza --icons --group-directories-first'
alias cat='bat --style=plain --paging=never'
alias grep='rg || grep'

# Git branch in prompt
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats '(%b)'
zstyle ':vcs_info:git:*' actionformats '(%b|%a)'

# ----------- Kali Linux style prompt -----------
PROMPT=$'%F{cyan}┌──(%n㉿%m)-[%~]${vcs_info_msg_0_}\n└─%# %f'
EOF

# ---------- Step 6: Termux extra keys ----------
cat > ~/.termux/termux.properties <<'EOF'
extra-keys = [ \
 ['ESC','/','-','HOME','UP','END','PGUP'], \
 ['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN'] \
]
EOF
termux-reload-settings

# ---------- Step 7: Auto-start Zsh ----------
if ! grep -q "exec zsh" "$HOME/.bashrc" 2>/dev/null; then
    echo '[[ $- == *i* ]] && exec zsh' >> "$HOME/.bashrc"
fi

log "✔ Kaliify setup completed!"
warn "Previous configs saved in $backup_dir"
warn "Restart Termux to apply changes."extra-keys = [ \
 ['ESC','/','-','HOME','UP','END','PGUP'], \
 ['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN'] \
]
EOF
termux-reload-settings

# ---------- Step 6: Auto-start Zsh ----------
if ! grep -q "exec zsh" "$HOME/.bashrc" 2>/dev/null; then
    echo '[[ $- == *i* ]] && exec zsh' >> "$HOME/.bashrc"
fi

log "All done! Restart Termux to enjoy your Kali-like shell."
warn "Your previous configs are saved in $backup_dir"
