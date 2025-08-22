#!/data/data/com.termux/files/usr/bin/bash
# ==========================================================
#  Kaliify-Termux Uninstaller
#  License: Apache-2.0
# ==========================================================

set -e

backup_root="$HOME/.kaliify-backups"

log() { echo -e "\033[1;32m[+] $*\033[0m"; }
warn() { echo -e "\033[1;33m[!] $*\033[0m"; }
err() { echo -e "\033[1;31m[✘] $*\033[0m"; }

# ---------- Step 1: Restore configs ----------
if [ -d "$backup_root" ]; then
    latest_backup=$(ls -d "$backup_root"/* | sort -r | head -n1)
    if [ -n "$latest_backup" ]; then
        log "Restoring configs from backup: $latest_backup"
        cp -rf "$latest_backup/." "$HOME/"
    else
        warn "No backups found in $backup_root"
    fi
else
    warn "No backup directory found ($backup_root)"
fi

# ---------- Step 2: Remove custom configs ----------
log "Cleaning custom configs..."
rm -f "$HOME/.zshrc"
rm -f "$HOME/.hushlogin"

# termux properties reset
if [ -f "$HOME/.termux/termux.properties" ]; then
    rm -f "$HOME/.termux/termux.properties"
    termux-reload-settings
fi

# ---------- Step 3: Remove symlinks ----------
[ -L "$PREFIX/bin/bat" ] && rm "$PREFIX/bin/bat"
[ -L "$PREFIX/bin/fd" ] && rm "$PREFIX/bin/fd"

# ---------- Step 4: Reset shell to bash ----------
if grep -q "exec zsh" "$HOME/.bashrc" 2>/dev/null; then
    log "Removing zsh auto-start from .bashrc"
    sed -i '/exec zsh/d' "$HOME/.bashrc"
fi

# ---------- Step 5: Optional package removal ----------
echo
warn "Do you want to remove packages installed by Kaliify? (y/n)"
read -r choice
if [ "$choice" = "y" ]; then
    log "Removing packages..."
    pkg uninstall -y python git whois curl wget tar unzip neofetch tmux \
        zsh eza fzf fd rg bat || true
fi

log "Uninstall complete. Restart Termux to apply changes."
