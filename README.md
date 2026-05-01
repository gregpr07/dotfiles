# dotfiles

My personal shell + terminal setup. Powerlevel10k prompt, oh-my-zsh, tmux, opinionated git config with [delta](https://github.com/dandavison/delta).

Works on **macOS** (homebrew) and **Linux** (apt — Ubuntu/Debian).

## What's in here

| File | Purpose |
| --- | --- |
| `zshrc` | Minimal zsh config — p10k + plugins + a couple of Claude aliases |
| `tmux.conf` | tmux keybinds, mouse, copy-mode, status line |
| `p10k.zsh` | Powerlevel10k prompt config |
| `gitconfig` | git with delta as pager, side-by-side diffs, Dracula syntax theme |
| `gitignore_global` | repo-wide ignores (`.worktrees`) |
| `config/ghostty/config` | Ghostty terminal settings |
| `config/git/ignore` | another global git ignore (Claude's local settings) |
| `vimrc` | `syntax on`. that's it. |

## Install (humans)

```sh
git clone https://github.com/gregpr07/dotfiles.git ~/Developer/dotfiles
~/Developer/dotfiles/install.sh
```

The installer is idempotent — safe to re-run. It:
1. Installs `zsh`, `git`, `git-delta` via apt or brew
2. Installs oh-my-zsh, powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting
3. Symlinks the dotfiles into `~` (existing files are backed up to `*.bak.<timestamp>`)
4. On Linux, appends a one-liner to `~/.bashrc` so interactive SSH sessions auto-launch zsh **without** running `chsh` — the login shell stays `bash` so non-interactive tooling keeps working unchanged

Open a new shell when it's done.

## Install (agents)

If you're an LLM agent setting these up on a remote machine for me, here's the one-shot:

```sh
ssh <host> 'git clone https://github.com/gregpr07/dotfiles.git ~/dotfiles && bash ~/dotfiles/install.sh'
```

Then reconnect with `ssh <host>` — you should land in zsh with the powerlevel10k prompt.

**Verification checklist:**
- `echo $SHELL` is still `/bin/bash` (login shell unchanged — this is intentional)
- `echo $ZSH_VERSION` is non-empty (interactive shell is zsh)
- `echo $ZSH_THEME` prints `powerlevel10k/powerlevel10k`
- `alias c` prints `c=yolo`
- `git config --get core.pager` prints `delta`
- `tmux -V` and `delta --version` both work

**Rollback:** the installer never `chsh`s. If something breaks:
```sh
cp ~/.bashrc.dotfiles-bak ~/.bashrc   # restore bashrc
# remove ~/.zshrc symlink if you want to fully revert; bash will pick up again on next login
```

**Font note:** Powerlevel10k icons render in the *local* terminal emulator, not on the remote. If icons show as boxes, install [MesloLGS NF](https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k) (or any Nerd Font) in your local terminal.

## Manual install

If you don't want to run the script:

```sh
ln -sf ~/Developer/dotfiles/zshrc            ~/.zshrc
ln -sf ~/Developer/dotfiles/tmux.conf        ~/.tmux.conf
ln -sf ~/Developer/dotfiles/p10k.zsh         ~/.p10k.zsh
ln -sf ~/Developer/dotfiles/gitconfig        ~/.gitconfig
ln -sf ~/Developer/dotfiles/gitignore_global ~/.gitignore_global
ln -sf ~/Developer/dotfiles/vimrc            ~/.vimrc
mkdir -p ~/.config/ghostty ~/.config/git
ln -sf ~/Developer/dotfiles/config/ghostty/config ~/.config/ghostty/config
ln -sf ~/Developer/dotfiles/config/git/ignore     ~/.config/git/ignore
```

You'll still need `zsh`, `git`, `git-delta`, oh-my-zsh + powerlevel10k + the two zsh plugins on the box.
