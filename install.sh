#!/usr/bin/env bash
# dotfiles installer — idempotent, safe to re-run
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +%Y%m%d-%H%M%S)"
OS="$(uname -s)"

say()   { printf '\033[36m==>\033[0m %s\n' "$*"; }
ok()    { printf '\033[32m✓\033[0m %s\n' "$*"; }
warn()  { printf '\033[33m!\033[0m %s\n' "$*"; }

backup() {
  local f="$1"
  if [ -e "$f" ] && [ ! -L "$f" ]; then
    mv "$f" "$f.bak.$TS"
    warn "backed up $f -> $f.bak.$TS"
  elif [ -L "$f" ]; then
    rm "$f"
  fi
}

link() {
  local src="$DOTFILES/$1"
  local dst="$HOME/$2"
  mkdir -p "$(dirname "$dst")"
  backup "$dst"
  ln -s "$src" "$dst"
  ok "$dst -> $src"
}

install_ai_instructions() {
  link ai/me.md     .codex/AGENTS.md
  link ai/me.md     .claude/me.md
  link ai/CLAUDE.md .claude/CLAUDE.md
}

if [ "$#" -eq 1 ] && [ "$1" = "--instructions-only" ]; then
  say "Symlinking global Codex and Claude Code instructions…"
  install_ai_instructions
  ok "AI instructions installed. Start fresh Codex and Claude Code sessions."
  exit 0
elif [ "$#" -ne 0 ]; then
  warn "Usage: $0 [--instructions-only]"
  exit 2
fi

# ─── 1. Install dependencies ─────────────────────────────────────────────
say "Installing zsh, git, git-delta…"
if [ "$OS" = "Linux" ] && command -v apt-get >/dev/null; then
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq zsh git curl git-delta tmux
elif [ "$OS" = "Darwin" ] && command -v brew >/dev/null; then
  brew install zsh git git-delta tmux >/dev/null
else
  warn "Unsupported OS or missing apt/brew — install zsh, git, git-delta, tmux manually."
fi

# ─── 2. oh-my-zsh + p10k + plugins ───────────────────────────────────────
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  say "Installing oh-my-zsh…"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" >/dev/null
fi
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ] && \
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k" >/dev/null 2>&1 && \
  ok "powerlevel10k installed"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && \
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" >/dev/null 2>&1 && \
  ok "zsh-autosuggestions installed"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && \
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" >/dev/null 2>&1 && \
  ok "zsh-syntax-highlighting installed"

# ─── 3. tmux plugins (catppuccin theme + cpu + battery) ──────────────────
TMUX_PLUGINS="$HOME/.config/tmux/plugins"
mkdir -p "$TMUX_PLUGINS/catppuccin" "$TMUX_PLUGINS/tmux-plugins"
[ ! -d "$TMUX_PLUGINS/catppuccin/tmux" ] && \
  git clone --depth=1 https://github.com/catppuccin/tmux.git "$TMUX_PLUGINS/catppuccin/tmux" >/dev/null 2>&1 && \
  ok "catppuccin tmux installed"
[ ! -d "$TMUX_PLUGINS/tmux-plugins/tmux-cpu" ] && \
  git clone --depth=1 https://github.com/tmux-plugins/tmux-cpu.git "$TMUX_PLUGINS/tmux-plugins/tmux-cpu" >/dev/null 2>&1 && \
  ok "tmux-cpu installed"
[ ! -d "$TMUX_PLUGINS/tmux-plugins/tmux-battery" ] && \
  git clone --depth=1 https://github.com/tmux-plugins/tmux-battery.git "$TMUX_PLUGINS/tmux-plugins/tmux-battery" >/dev/null 2>&1 && \
  ok "tmux-battery installed"

# ─── 4. Symlink dotfiles ─────────────────────────────────────────────────
say "Symlinking configs…"
link zshrc            .zshrc
link tmux.conf        .tmux.conf
link p10k.zsh         .p10k.zsh
link gitconfig        .gitconfig
link gitignore_global .gitignore_global
link vimrc            .vimrc
link config/ghostty/config .config/ghostty/config
link config/git/ignore     .config/git/ignore
install_ai_instructions

# ─── 5. On Linux, auto-launch zsh from interactive .bashrc ───────────────
# (no chsh — login shell stays bash, so non-interactive ssh & system tooling
#  keep working unchanged)
if [ "$OS" = "Linux" ] && [ -f "$HOME/.bashrc" ]; then
  MARKER="# >>> dotfiles auto-launch zsh"
  if ! grep -qF "$MARKER" "$HOME/.bashrc"; then
    [ ! -f "$HOME/.bashrc.dotfiles-bak" ] && cp "$HOME/.bashrc" "$HOME/.bashrc.dotfiles-bak"
    cat >> "$HOME/.bashrc" <<'EOF'

# >>> dotfiles auto-launch zsh
[ -t 1 ] && [ -z "$ZSH_VERSION" ] && command -v zsh >/dev/null && exec zsh -l
# <<<
EOF
    ok "added auto-launch zsh to ~/.bashrc"
  fi
fi

ok "Done. Open a new shell."
