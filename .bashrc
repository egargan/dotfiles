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

# Print current SSH agent
alias shocket='echo $(find /tmp -path '*/ssh-*' -name 'agent*' -uid $(id -u) 2>/dev/null | tail -n1)'

# Git aliases
alias gst='git status'
alias  gd='git diff'
alias gdc='git diff --cached'
alias gcm='git commit'
alias gck='git checkout'
alias  ga='git add'
