# Powerlevel10k instant prompt — keep at top of file
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git z)
source $ZSH/oh-my-zsh.sh

# Syntax highlighting — must be sourced last
# Disabled for SSH responsiveness
# source $ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

# p10k prompt config
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Claude Code
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
alias yolo="claude --dangerously-skip-permissions"
alias c="yolo"
alias x="codex --yolo"

# yazi - cd to directory on exit
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
