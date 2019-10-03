# .bashrc

export HISTSIZE=10000
export HISTFILESIZE=2000
# Don't save duplicate subsequent commands + commands beginning with space
export HISTCONTROL=ignoreboth

# Source global bashrc if any
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# source machine-specific bashrc not for tracking with git
if [ -f ~/.bashrc.private ]; then
    . ~/.bashrc.private
fi

## Env vars
export PAGER=less
export EDITOR=vim

## Aliases
# Alias tmux to tmux w/ colours enabled
alias tmux='tmux -2'

# Print current SSH agent
alias shocket='echo $(find /tmp -path '*/ssh-*' -name 'agent*' -uid $(id -u) 2>/dev/null | tail -n1)'

alias ls='ls --color'

# Git aliases
alias gst='git status'
alias  gd='git diff'
alias gdc='git diff --cached'
alias gcm='git commit'
alias gco='git checkout'
alias  ga='git add'

# Get + run git command auto-completion script
# Is sometimes already installed with git, but it's a faff looking through different distro's install locs
if [ ! -f ~/.git-completion.bash ]; then
    echo 'Downloading git-completion script..';
    curl -s -o ~/.git-completion.bash \
    https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
fi
source ~/.git-completion.bash
