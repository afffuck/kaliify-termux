# Kaliify-Termux

Turn your Termux into a **Kali Linux inspired environment** with a beautiful prompt, smart defaults, and essential tools — all in one command.

<p align="center">
  <img src="https://img.shields.io/badge/platform-termux-green?logo=android" alt="Termux">
  <img src="https://img.shields.io/badge/shell-bash-blue?logo=gnu-bash" alt="Bash">
  <img src="https://img.shields.io/badge/license-Apache-2.0-yellow" alt="License">
</p>

---

## ✨ Features
- 🖥️ **Kali-style prompt** with colours and user@host formatting  
- ⚡ **Autocomplete & suggestions** for installed commands  
- 📦 Auto-installs **Python, Git, whois, curl, wget, fzf, neofetch, and more**  
- 🧹 Removes Termux startup message  
- 🔄 Safe installer (only installs missing packages)  
- 🗑️ Full uninstaller included  

---

## 🚀 Installation

Clone and run the installer:

```bash
pkg install -y git
git clone https://github.com/afffuck/kaliify-termux.git
cd kaliify-termux
chmod +x kaliify-termux.sh
./kaliify-termux.sh
