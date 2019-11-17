# .bashrc

# Source global bashrc if any
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

## Env vars
export PAGER=less
export EDITOR=vim

export HISTSIZE=10000
export HISTFILESIZE=2000
export HISTCONTROL=ignoreboth   # Don't save duplicate subsequent commands / those beginning with space

## Aliases
alias tmux='tmux -2'            # Alias tmux to tmux w/ colours enabled
alias sctl='sudo systemctl'
alias   se='sudoedit'

# Print current SSH agent
alias shocket='echo $(find /tmp -path '*/ssh-*' -name 'agent*' -uid $(id -u) 2>/dev/null | tail -n1)'

# Colour ls output
if [[ "$OSTYPE" == darwin* ]]; then
    alias ls='ls -G'
else
    alias ls='ls --color=auto'
fi

# Git aliases
alias gst='git status'
alias  gd='git diff'
alias gdn='git diff --name-only'
alias gdc='git diff --cached'
alias gcm='git commit'
alias gco='git checkout'
alias  ga='git add'

# Display tmux sessions, if any exist
if hash tmux &>/dev/null; then
    TMUX_LS=$(tmux ls &>/dev/null)
    if [[ $TMUX_LS =~ ^[0-9]: && ! $TMUX_LS =~ \(attached\)$ ]]; then
        echo "Active tmux sessions:"
        echo "$TMUX_LS"
    fi
fi

# Get + run git command auto-completion script
# Is sometimes already installed with git, but it's a faff looking through different distros' install locs
if [ ! -f ~/.git-completion.bash ]; then
    echo 'Downloading git-completion script..';
    curl -s -o ~/.git-completion.bash \
    https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
fi
source ~/.git-completion.bash

# Source machine-specific bashrc not for tracking with git
if [ -f ~/.bashrc.private ]; then
    . ~/.bashrc.private
fi
