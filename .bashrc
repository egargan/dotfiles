# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

## Env vars
export PAGER=less
export EDITOR=vim

## Aliases
# Alias tmux to tmux w/ colours enabled
alias tmux='tmux -2'

# Git aliases
alias gst='git status'
alias  gd='git diff'
alias gdc='git diff --cached'
alias gcm='git commit'
alias gck='git checkout'
alias  ga='git add'
