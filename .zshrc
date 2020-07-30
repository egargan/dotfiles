# Source global bashrc if any
if [ -f /etc/zshrc ]; then
    . /etc/zshrc
fi

## Env vars and options

export PAGER=less
export EDITOR=vim

export HISTFILE=~/.zsh_history

export SAVEHIST=10000           # Max number of entries in command history
export HISTSIZE=10000           # Number of entries read into session history

setopt INC_APPEND_HISTORY_TIME  # Share history file between multiple shells
setopt HIST_IGNORE_SPACE        # Don't record space-prefixed commands
setopt HIST_FIND_NO_DUPS        # Ignore duplicates when searching history

## Aliases

alias tmux='tmux -2'            # Alias tmux to tmux w/ colours enabled

alias sctl='sudo systemctl'
alias   se='sudo -e'

alias   cb='xclip -selection clipboard'

alias gst='git status'
alias  gd='git diff'
alias gdn='git diff --name-only'
alias gdu='git diff --name-only --diff-filter=U'  # List files w/ merge conflicts
alias gdc='git diff --cached'
alias gco='git checkout'
alias gad='git add'
alias  gc='git commit'
alias gca='git commit --amend'
alias gri='git rebase -i'
alias grc='git rebase --continue'

# Print current SSH agent
alias shocket='echo $(find /tmp -path "*/ssh-*" -name "agent*" -uid $(id -u) 2>/dev/null | tail -n1)'

# Colour ls output
if [[ "$OSTYPE" == darwin* ]]; then
    alias ls='ls -G'
else
    alias ls='ls --color=auto'
fi

## Misc

bindkey -e                              # Enable emacs bindings (ctrl-w, ctrl-r, etc.)

autoload -Uz compinit && compinit       # Initialize zsh tab completion

export PROMPT='%2~ %F{7}%# %f'          # Customise prompt

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh  # Enable fzf bindings

# Have fzf use ripgrep
export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git'"

# Display unattached tmux sessions, if any exist
if hash tmux &>/dev/null; then
    local TMUX_LS=$(tmux ls 2>/dev/null)

    if [[ $TMUX_LS =~ ^'[0-9]:' && ! $TMUX_LS =~ '\(attached\)'$ ]]; then
        echo "Active tmux sessions:"
        echo "$TMUX_LS"
    fi
fi

# Source machine-specific zshrc not for tracking with git
if [ -f ~/.zshrc.private ]; then
    . ~/.zshrc.private
fi
