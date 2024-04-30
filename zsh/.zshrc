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

# Enable Ctrl-x Ctrl-e to edit current command line
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# Hook direnv into shell
eval "$(direnv hook zsh)"

# Fuzzy find sessions, i.e. projects
bindkey -s ^f "tmux-sessionizer\n"

# Copy the current command to the clipboard (for macOS!)
copy_line_to_clipboard() { echo $BUFFER | tr -d '\n' | pbcopy }
zle -N copy_line_to_clipboard
bindkey '^Y' copy_line_to_clipboard

# -- History ------------------------------------------------------------------

export HISTFILE=~/.zsh_history
export SAVEHIST=100000                 # Max number of entries in command history
export HISTSIZE=100000                 # Number of entries read into session history
setopt append_history          # append to history file
setopt extended_history        # write the history file in the ':start:elapsed;command' format
setopt hist_find_no_dups       # don't display a previously found event
setopt hist_ignore_all_dups    # delete an old recorded event if a new event is a duplicate
setopt hist_ignore_dups        # don't record an event that was just recorded again
setopt hist_ignore_space       # don't record an event starting with a space
setopt hist_reduce_blanks      # remove superfluous blanks from each command line being added to the history list
setopt hist_save_no_dups       # don't write a duplicate event to the history file
setopt hist_verify             # don't execute immediately upon history expansion
setopt inc_append_history      # write to the history file immediately, not when the shell exits
unsetopt share_history         # don't share history between all sessions


# == Tools ===================================================================

# -- junegunn/fzf ------------------------------------------------------------

# Add fzf to PATH, if not already
if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi

# Setup completion and keybindings
[[ $- == *i* ]] && source "/opt/homebrew/opt/fzf/shell/completion.zsh" 2> /dev/null

FZF_BINDINGS_SETUP_PATH="/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
[[ -f "$FZF_BINDINGS_SETUP_PATH" ]] && source "$FZF_BINDINGS_SETUP_PATH"

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
  grep -o "[a-f0-9]\{7,\}" | head -1
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
  [[ "$(cat package.json | jq -C '.scripts' | sed '1d; $d' | fzf-down-preview --ansi --tac --expect='ctrl-l' --header='Enter for name, ctrl-l for full command')" =~ '^(ctrl-l)?[[:space:]]*"([^"]+)":[[:space:]]*"(.+)",?$' ]] && if [[ "$match[1]" == "ctrl-l" ]]; then echo "$match[3]"; else echo "$match[2]"; fi
}

_np() {
  jq -r -C '.dependencies,.devDependencies | keys[]' package.json | fzf-down-preview --ansi --multi
}

join-lines() {
  local item
  while read item; do
    echo -n "${(q)item} "
  done
}

# For each function above, create a widget and register a binding
for key in gb gt gl gs gn gd gc go ns np; do
  eval "fzf-$key-widget() {
    local result=\$(_$key);
    zle reset-prompt;
    LBUFFER+=\$result
  }"
  eval "zle -N fzf-$key-widget"
  eval "bindkey '^$key' fzf-$key-widget"
done

# -- sharkdp/bat -------------------------------------------------------------

export BAT_THEME="Nord"

# -- zsh-syntax-highlighting  -------------------------------------------------

MACOS_SYNTAX_HL_SETUP_PATH="/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[[ -f "$MACOS_SYNTAX_HL_SETUP_PATH" ]] && source "$MACOS_SYNTAX_HL_SETUP_PATH"

LINUX_SYNTAX_HL_SETUP_PATH="/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[[ -f "$LINUX_SYNTAX_HL_SETUP_PATH" ]] && source "$LINUX_SYNTAX_HL_SETUP_PATH"


# -- Volta --------------------------------------------------------------------

export VOLTA_HOME="$HOME/.volta"
export PATH="$PATH:$VOLTA_HOME/bin"


# == Prompt ===================================================================

# Enable checking for (un)staged changes, enabling use of %u and %c
zstyle ':vcs_info:*' check-for-changes true

# Set custom strings for an unstaged vcs repo changes (*) and staged changes (+)
zstyle ':vcs_info:*' unstagedstr "'"
zstyle ':vcs_info:*' stagedstr "'"

# Set the format of the Git information for vcs_info
zstyle ':vcs_info:git:*' formats       ' (%b%u%c)'
zstyle ':vcs_info:git:*' actionformats ' (%b|%a%u%c)'

# Preprare variables used in prompt
precmd() {
  vcs_info
  aws_profile=${AWS_PROFILE:+ [${AWS_PROFILE}]}
}

setopt PROMPT_SUBST
export PROMPT='%B%F{blue}%2~%b%F{cyan}${vcs_info_msg_0_}%b%F{yellow}${aws_profile} %B%F{black}%# %b%f'

# == Env ======================================================================

export PAGER=less
export EDITOR=vim

export PATH=$PATH:~/.local/bin:~/.local/scripts

# == Aliases ==================================================================

alias tmux='tmux -2'                        # tmux with colours

alias   rg='rg --no-ignore-vcs'             # Tell rg to not read and follow .gitignore
alias sctl='sudo systemctl'
alias   se='sudo -e'
alias   cb='xclip -selection clipboard'

alias   lg='lazygit'

# Print path to current SSH socket file
alias shocket='echo $(find /tmp -path "*/ssh-*" -name "agent*" -uid $(id -u) 2>/dev/null | tail -n1)'

# If nvim is installed, alias vim and vi to it
if [[ "$(command -v nvim)" ]]; then
  alias vim='nvim'
  alias vi='nvim'
  alias v='nvim'
  alias vl='nvim -u ~/.config/nvim/lua/inits/light.lua'
  alias vd='nvim -u ~/.config/nvim/lua/inits/diffview.lua'
fi

# Alias ls to ls with colours enabled (of course macOS' uses a different option)
if [[ "$OSTYPE" == darwin* ]]; then
  alias ls='ls -G'
else
  alias ls='ls --color=auto'
fi

alias pj='python3 -m json.tool'


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
alias gfa='git fetch --all'
alias gpl='git pull origin $(git rev-parse --abbrev-ref HEAD)'


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

# Disable pager in GitHub CLI
export GH_PAGER=""

# Source private, host-specific zshrc not for tracking with git
if [ -f ~/.zshrc.private ]; then
    . ~/.zshrc.private
fi
