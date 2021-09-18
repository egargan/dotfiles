# Source global .zshrc, if one exists
if [ -f /etc/zshrc ]; then
  . /etc/zshrc
fi


# == Bindings + Functions =====================================================

autoload -U colors                     # Enable 'colors[..]' for setting term colors
bindkey -e                             # Enable emacs bindings (ctrl-w, ctrl-r, etc.)
bindkey \^U backward-kill-line         # Don't delete entire line on ctrl-u
autoload -Uz compinit && compinit      # Initialize zsh tab completion

# Enable Ctrl-x Ctrl-e to edit current command line
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# Hook direnv into shell
eval "$(direnv hook zsh)"


# == Plugins =================================================================

if [[ -f '/usr/local/opt/zplug/init.zsh' ]]; then
  source /usr/local/opt/zplug/init.zsh
elif [[ -f '~/.zplug/init.zsh' ]]; then
  source ~/.zplug/init.zsh
fi

# ----------------------------------------------------------------------------

# Have zplug manage itself like the other plugins
zplug 'zplug/zplug', hook-build: 'zplug --self-manage'

# Brings in functions and vars to tell us Git info
zplug "plugins/git", from:oh-my-zsh

# Multi-purpose fuzzy text searcher
zplug "junegunn/fzf", as:command, hook-build:"./install --bin", use:"bin/{fzf-tmux,fzf}"

# Command line syntax highlighting
zplug "zsh-users/zsh-syntax-highlighting"

# Cat w/ syntax highlighting
zplug "sharkdp/bat", as:command, from:gh-r, rename-to:bat

# ----------------------------------------------------------------------------

# Inform of any uninstalled plugins
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

# Load plugins
zplug load


# == Plugin Config ===========================================================

# -- junegunn/fzf ------------------------------------------------------------

# Setup bindings and autocompletion
source ~/.zplug/repos/junegunn/fzf/shell/key-bindings.zsh
source ~/.zplug/repos/junegunn/fzf/shell/completion.zsh

# Have fzf use ripgrep
export FZF_DEFAULT_COMMAND="rg --files --no-ignore-vcs --hidden --follow --glob '!.git'"


# == Prompt ===================================================================

# TODO: groove me up
export PROMPT='%2~ %F{7}%# %f'        # Customise prompt string


# == Env ======================================================================

export PAGER=less
export EDITOR=vim

export HISTFILE=~/.zsh_history
export SAVEHIST=10000                 # Max number of entries in command history
export HISTSIZE=10000                 # Number of entries read into session history

setopt INC_APPEND_HISTORY_TIME        # Share history file between multiple shells
setopt HIST_IGNORE_SPACE              # Don't record space-prefixed commands
setopt HIST_FIND_NO_DUPS              # Ignore duplicates when searching history

export GIT_CEILING_DIRECTORIES=$HOME  # 'git ...' won't look as far as ~ when looking for repo

export PATH=$PATH:~/.local/bin


# == Aliases ==================================================================

alias tmux='tmux -2'                        # tmux with colours

alias   rg='rg --no-ignore-vcs'             # Tell rg to not read and follow .gitignore
alias sctl='sudo systemctl'
alias   se='sudo -e'
alias   cb='xclip -selection clipboard'

# Print path to current SSH socket file
alias shocket='echo $(find /tmp -path "*/ssh-*" -name "agent*" -uid $(id -u) 2>/dev/null | tail -n1)'

# If vimx is installed (vim with X11-y feature support, notably clipboard), alias it
if [[ "$(command -v vimx)" ]]; then
  alias vim='vimx'
  alias vi='vimx'
fi

# Alias ls to ls with colours enabled (of course macOS' uses a different option)
if [[ "$OSTYPE" == darwin* ]]; then
  alias ls='ls -G'
else
  alias ls='ls --color=auto'
fi

alias pj='python -m json.tool'


# -- Git ----------------------------------------------------------------------

alias gst='git status'
alias tsg='tig status'
alias gd='git diff'
alias gdn='git diff --name-only'
alias gdu='git diff --name-only --diff-filter=U'     # List files w/ merge conflicts
alias gdc='git diff --cached'
alias gdcn='git diff --cached --name-only'
alias gco='git checkout'
alias gad='git add'
alias grs='git reset'
alias gc='git commit'
alias gca='git commit --amend'
alias gri='git rebase -i'
alias grc='git rebase --continue'
alias gs='git show'
alias gsn='git show --pretty=format:'' --name-only'  # List filenames only


# == Status Messages ==========================================================

# Display unattached tmux sessions, if any exist
if hash tmux &>/dev/null; then
  local TMUX_LS=$(tmux ls 2>/dev/null)

  if [[ $TMUX_LS =~ ^'[0-9]:' && ! $TMUX_LS =~ '\(attached\)'$ ]]; then
    echo "Active tmux sessions:"
    echo "$TMUX_LS"
  fi
fi


# Source private, host-specific zshrc not for tracking with git
if [ -f ~/.zshrc.private ]; then
    . ~/.zshrc.private
fi
