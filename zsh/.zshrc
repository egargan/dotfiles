# Colors
RED='\033[31m';
GREEN='\033[32m';
RESET='\033[0m';

# Source global .zshrc, if one exists
if [ -f /etc/zshrc ]; then
  . /etc/zshrc
fi


# == Bindings + Functions =====================================================

autoload -U colors                     # Enable 'colors[..]' for setting term colors
bindkey -e                             # Enable emacs bindings (ctrl-w, ctrl-r, etc.)
bindkey \^U backward-kill-line         # Don't delete entire line on ctrl-u
autoload -Uz compinit && compinit      # Initialize zsh tab completion

autoload -Uz vcs_info
precmd() { vcs_info }

# Enable Ctrl-x Ctrl-e to edit current command line
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# Hook direnv into shell
eval "$(direnv hook zsh)"

# Fuzzy find sessions, i.e. projects
bindkey -s ^f "tmux-sessionizer\n"


# == Plugins =================================================================

# Setup zplug
if [ -n "$ZPLUG_HOME" ]; then
  source $ZPLUG_HOME/init.zsh
else
  if [[ -f '/usr/local/opt/zplug/init.zsh' ]]; then
    source /usr/local/opt/zplug/init.zsh
    export ZPLUG_HOME=/usr/local/opt/zplug
  elif [[ -f "$HOME/.zplug/init.zsh" ]]; then
    source ~/.zplug/init.zsh
    export ZPLUG_HOME=$HOME/.zplug
  fi
fi

# ----------------------------------------------------------------------------

# Have zplug manage itself like the other plugins
zplug 'zplug/zplug', hook-build: 'zplug --self-manage'

# Multi-purpose fuzzy text searcher
zplug "junegunn/fzf", as:command, hook-build:"./install --bin", use:"bin/{fzf-tmux,fzf}"

# Command line syntax highlighting
zplug "zsh-users/zsh-syntax-highlighting"

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
source $ZPLUG_REPOS/junegunn/fzf/shell/key-bindings.zsh
source $ZPLUG_REPOS/junegunn/fzf/shell/completion.zsh

# Have fzf use ripgrep
export FZF_CTRL_T_COMMAND="rg --files --no-ignore-vcs --hidden --follow --glob '!.git'"

fzf-down-preview() {
  fzf --reverse --height 50% --min-height 20 --bind ctrl-k:toggle-preview --preview-window right:60%:hidden "$@"
}

_gb() {
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-down-preview --ansi --multi --tac --preview \
  'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1)' |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/origin/##'
}

_gt() {
  git tag --sort -version:refname |
  fzf-down-preview --multi --preview 'git show --color=always {}'
}

_gl() {
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf-down-preview --ansi --no-sort --multi --bind 'ctrl-s:toggle-sort' --delimiter '[a-z0-9\-]{7,}' --nth 3.. \
    --header 'Ctrl-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always' |
  grep -o "[a-f0-9]\{7,\}"
}

_gs() {
  git stash list | fzf-down-preview -d: --preview 'git show --color=always {1}' |
  cut -d: -f1
}

_gd() {
  echo "${RED}$(git ls-files --others --exclude-standard; git diff --name-only;)${RESET}" |
  fzf-down-preview --ansi --multi --preview 'git diff {}' |
  tr '\n' ' '
}

_gc() {
  echo "${GREEN}$(git diff --cached --name-only)${RESET}" |
  fzf-down-preview --ansi --multi --preview 'git diff --cached {}' |
  tr '\n' ' '
}

_go() {
  git branch --show-current
}

_ns() {
  cat package.json | jq -C '.scripts' | sed '1d; $d' |
    fzf-down-preview --ansi --multi --tac |
    sed -r 's/^[[:space:]]*"([^"]+)".*$/\1/'
}

join-lines() {
  local item
  while read item; do
    echo -n "${(q)item} "
  done
}

# For each function above, create a widget and register a binding
for key in gb gt gl gs gn gd gc go ns; do
  eval "fzf-$key-widget() {
    git rev-parse HEAD > /dev/null 2>&1 || return;
    local result=\$(_$key);
    zle reset-prompt;
    LBUFFER+=\$result
  }"
  eval "zle -N fzf-$key-widget"
  eval "bindkey '^$key' fzf-$key-widget"
done

# -- sharkdp/bat -------------------------------------------------------------

export BAT_THEME="Nord"


# == Prompt ===================================================================

# Enable checking for (un)staged changes, enabling use of %u and %c
zstyle ':vcs_info:*' check-for-changes true

# Set custom strings for an unstaged vcs repo changes (*) and staged changes (+)
zstyle ':vcs_info:*' unstagedstr "'"
zstyle ':vcs_info:*' stagedstr "'"

# Set the format of the Git information for vcs_info
zstyle ':vcs_info:git:*' formats       ' (%b%u%c)'
zstyle ':vcs_info:git:*' actionformats ' (%b|%a%u%c)'

setopt PROMPT_SUBST
export PROMPT='%B%F{blue}%2~%b%F{cyan}${vcs_info_msg_0_} %B%F{black}%# %b%f'


# == Env ======================================================================

export PAGER=less
export EDITOR=vim

export HISTFILE=~/.zsh_history
export SAVEHIST=10000                 # Max number of entries in command history
export HISTSIZE=10000                 # Number of entries read into session history

setopt INC_APPEND_HISTORY_TIME        # Share history file between multiple shells
setopt HIST_IGNORE_SPACE              # Don't record space-prefixed commands
setopt HIST_FIND_NO_DUPS              # Ignore duplicates when searching history

export PATH=$PATH:~/.local/bin:~/.local/scripts


# == Aliases ==================================================================

alias tmux='tmux -2'                        # tmux with colours

alias   rg='rg --no-ignore-vcs'             # Tell rg to not read and follow .gitignore
alias sctl='sudo systemctl'
alias   se='sudo -e'
alias   cb='xclip -selection clipboard'

# Print path to current SSH socket file
alias shocket='echo $(find /tmp -path "*/ssh-*" -name "agent*" -uid $(id -u) 2>/dev/null | tail -n1)'

# If nvim is installed, alias vim and vi to it
if [[ "$(command -v nvim)" ]]; then
  alias vim='nvim'
  alias vi='nvim'
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
alias gdn='git diff --name-only --relative'
alias gdu='git diff --name-only --relative --diff-filter=U'     # List files w/ merge conflicts
alias gdc='git diff --cached --relative'
alias gdcn='git diff --cached --name-only --relative'
alias gco='git checkout'
alias gad='git add'
alias grs='git reset'
alias grsh='git reset --hard'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'
alias gri='git rebase -i'
alias grc='git rebase --continue'
alias gs='git show'
alias gsn='git show --pretty=format:'' --name-only --relative'  # List filenames only
alias gp='git push'
alias gpf='git push --force'


# == Status Messages ==========================================================

# Display unattached tmux sessions, if any exist
if hash tmux &>/dev/null; then
  local TMUX_LS=$(tmux ls 2>/dev/null)

  if [[ -z "$TMUX" && $TMUX_LS =~ ^'[0-9]:' && ! $TMUX_LS =~ '\(attached\)'$ ]]; then
    echo "Active tmux sessions:"
    echo "$TMUX_LS"
  fi
fi

# == Misc ====================================================================

# Support mouse input in less
export LESS='--mouse --wheel-lines=3'


# Source private, host-specific zshrc not for tracking with git
if [ -f ~/.zshrc.private ]; then
    . ~/.zshrc.private
fi
