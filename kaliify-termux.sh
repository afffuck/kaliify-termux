#!/data/data/com.termux/files/usr/bin/bash
# ==========================================================
#  Kaliify-Termux
#  Turn your Termux into a clean Kali-like shell environment
#  Author: Afffuck
# My Telegram: xthefs
#  License: Apache-2.0
# ==========================================================

set -e

# ---------- Helpers ----------
timestamp=$(date +%Y%m%d-%H%M%S)
backup_dir="$HOME/.kaliify-backups/$timestamp"
mkdir -p "$backup_dir"

log() { echo -e "\033[1;32m[+] $*\033[0m"; }
warn() { echo -e "\033[1;33m[!] $*\033[0m"; }
err() { echo -e "\033[1;31m[✘] $*\033[0m"; }

# ---------- Safe package installer ----------
install_pkg() {
    for pkg in "$@"; do
        if ! command -v "$pkg" &>/dev/null; then
            log "Installing $pkg..."
            pkg install -y "$pkg"
        else
            log "$pkg already installed ✓"
        fi
    done
}

# ---------- Step 1: Install dependencies ----------
log "Updating package index..."
pkg update -y && pkg upgrade -y

install_pkg python git whois curl wget tar unzip neofetch tmux \
    zsh eza fzf fd rg bat

# Aliases compatibility (batcat vs bat, fd vs fdfind)
if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    ln -s "$(command -v batcat)" "$PREFIX/bin/bat"
fi
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    ln -s "$(command -v fdfind)" "$PREFIX/bin/fd"
fi

# ---------- Step 2: Remove Termux banner ----------
touch ~/.hushlogin

# ---------- Step 3: Backup old configs ----------
for f in .zshrc .bashrc .termux/termux.properties; do
    [ -f "$HOME/$f" ] && cp "$HOME/$f" "$backup_dir/"
done

# ---------- Step 4: Configure .zshrc ----------
cat > "$HOME/.zshrc" <<'EOF'
# ====== Zsh configuration (Kaliify) ======

# Colours
autoload -U colors && colors

# Prompt: user@host:path (git) $ with status and clock
PROMPT='%{$fg[cyan]%}%n%{$reset_color%}@%{$fg[blue]%}%m %{$fg[green]%}%~%{$reset_color%}$(git_prompt_info)
%{$fg[red]%}%(!.#.$)%{$reset_color%} '

RPROMPT='%{$fg[yellow]%}%D{%H:%M}%{$reset_color%}'

# Git prompt
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats '%{$fg[magenta]%}(%b)%{$reset_color%}'
zstyle ':vcs_info:git:*' actionformats '%{$fg[magenta]%}(%b|%a)%{$reset_color%}'
setopt prompt_subst

# History
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000
setopt appendhistory sharehistory histignoredups

# Completion
autoload -U compinit && compinit

# Tab menu
zstyle ':completion:*' menu select
bindkey -e

# Accept suggestions with → arrow
bindkey '^[[C' forward-word
autoload -Uz predict-on
predict-on

# Up/down for history
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Aliases
alias ls='eza --icons --group-directories-first'
alias cat='bat --style=plain --paging=never'
alias grep='rg'
alias ffind='fd'

# Neofetch on start
[ -x "$(command -v neofetch)" ] && neofetch
EOF

# ---------- Step 5: Termux extra-keys ----------
mkdir -p ~/.termux
cat > ~/.termux/termux.properties <<'EOF'
extra-keys = [ \
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
