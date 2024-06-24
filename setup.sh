#!/bin/zsh

# This script sets up a development environment on a new macOS machine.
#
# It installs Homebrew and a number of packages, creates and configures personal and work SSH keys
# for GitHub, clones egargan/dotfiles and stows them, and sets up Node via Volta.
#
# TODO: neovim setup: install mason and lazy plugins?
# TODO: cask install iterm2? download + add colorscheme to program files?
# TODO: cask install raycast?

set -eo pipefail

RESET='\e[0m'
CYAN='\e[1;36m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
RED='\e[1;31m'
GREY='\e[1;30m'
WHITE='\e[0;37m'
GREEN='\e[1;32m'
PURPLE='\e[1;35m'
BOLD_WHITE='\e[1;37m'


if [[ "$OSTYPE" != darwin* ]]; then
  printf "This script is not intended to run on non-macOS systems\n"
  exit 1
fi

if ! command -v git &> /dev/null; then
  printf "This script requires git, install it Homebrew or 'xcode-select --install'"
  exit 1
fi

function print_action() {
  printf "${CYAN}(>)${RESET} ${BOLD_WHITE}$1${RESET}\n\n"
}
function print_notice() {
  printf "${PURPLE}(!)${RESET} $1${RESET}\n\n"
}
function print_success() {
  printf "${GREEN}(✓)${RESET} $1${RESET}\n\n"
}
function print_question() {
  printf "${YELLOW}(?)${RESET} $1${RESET}"
}
function print_skip() {
  printf "${GREY}(-)${RESET} $1${RESET}\n\n"
}

function read_yn() {
  while IFS= read INPUT; do
    if [[ $INPUT =~ ^[Yy]$ ]]; then
      printf "Y"
      break
    elif [[ $INPUT =~ ^[Nn]$ ]]; then
      printf "N"
      break
    fi
  done
}

# -- Install Homebrew and deps ------------------------------------------------

print_action "Installing Homebrew"

#  Check if Homebrew is installed
if command -v brew &> /dev/null; then
  print_skip "Homebrew already installed, skipping"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  print_success "Homebrew installed successfully"
  sleep 3
fi

# TODO: can we split this list into lines of three?
HOMEBREW_DEPS=(
  "coreutils"
  "direnv"
  "fzf"
  "gh"
  "git-lfs"
  "jq"
  "lazygit"
  "neovim"
  "poetry"
  "ripgrep"
  "stow"
  "tig"
  "tmux"
  "tree"
  "volta"
  "zsh-syntax-highlighting"
)

INSTALLED_DEPS=$(brew list --formula)

for dep in "${HOMEBREW_DEPS[@]}"; do
  print_action "Installing ${dep} (homebrew)"

  if [[ $INSTALLED_DEPS =~ "${dep}" ]]; then
    print_skip "${dep} already installed, skipping"
    sleep .2
    continue
  fi

  HOMEBREW_NO_ENV_HINTS=1 brew install --quiet $dep
  printf "\n"
  print_success "${dep} installed successfully"
  sleep 2
done

# -- Setup SSH key for personal GitHub ---------------------------------------------

print_action "Personal GitHub SSH key setup"

if [[ -f ~/.ssh/egargan ]]; then
  print_question "~/.ssh/egargan key already exists, delete and create a new one?"
else
  print_question "Add a new SSH key to egargan GitHub?"
fi

printf " ${BOLD_WHITE}(y/n)${RESET} "
REPLY="$(read_yn)"
printf "\n"

if [[ "$REPLY" == "Y" ]]; then
  mkdir -p ~/.ssh
  [[ -f ~/.ssh/egargan ]] && rm -f ~/.ssh/egargan*
  ssh-keygen -t ed25519 -C "$(hostname)" -f ~/.ssh/egargan -P "" -q
  cat ~/.ssh/egargan.pub | pbcopy

  print_notice "Key has been added to clipboard, opening GitHub key settings page..."

  cat ~/.ssh/egargan.pub
  printf "\n"

  sleep 5
  open 'https://github.com/settings/ssh/new'

  print_question "Press any key to continue once key is added"
  printf "\n"

  read -k 1
fi

# -- Clone dotfiles from GitHub ---------------------------------------------

print_action "Installing dotfiles"

if [[ -d ~/personal/dotfiles ]]; then
  print_skip "Dotfiles already cloned, skipping download"
else
  mkdir -p ~/personal
  cd ~/personal

  GIT_SSH_COMMAND="ssh -i ~/.ssh/egargan" git clone git@github.com:egargan/dotfiles.git ~/personal/dotfiles
fi

cd ~/personal/dotfiles
make

printf "\n"
print_notice "Dotfiles cloned to ~/personal/dotfiles and stowed to ~"

# -- Set up work SSH key ---------------------------------------------

print_action "Work GitHub SSH key setup"

print_question "Add a new SSH key for work GitHub?"
printf " ${BOLD_WHITE}(y/n)${RESET} "
REPLY="$(read_yn)"
printf "\n"

if [[ "$REPLY" == "Y" ]]; then
  print_question "Enter work email address: "
  read WORK_GITHUB_EMAIL
  print_question "Enter work GitHub username: "
  read WORK_GITHUB_USERNAME

  [[ -f ~/.gitconfig-work ]] && rm -f ~/.gitconfig-work

  cat >~/.gitconfig-work <<EOL
[user]
  email = $WORK_GITHUB_EMAIL
  name = $WORK_GITHUB_USERNAME
[core]
  sshCommand = ssh -i ~/.ssh/$WORK_GITHUB_USERNAME
EOL

  print_notice "~/.gitconfig-work created, referring to ~/.ssh/$WORK_GITHUB_USERNAME key"

  mkdir -p ~/.ssh
  [[ -f ~/.ssh/$WORK_GITHUB_USERNAME ]] && rm -f ~/.ssh/$WORK_GITHUB_USERNAME*
  ssh-keygen -t ed25519 -C "$(hostname)" -f ~/.ssh/$WORK_GITHUB_USERNAME -P "" -q
  printf "\n"
  cat ~/.ssh/$WORK_GITHUB_USERNAME.pub | pbcopy

  print_notice "Work key added to clipboard, add to work GitHub key settings"

  cat ~/.ssh/$WORK_GITHUB_USERNAME.pub
  printf "\n"

  sleep 2

  print_question "Press any key to continue once key is added"
  read -k 1
  printf "\n"
fi

# -- Node + Volta setup ---------------------------------------------

print_action "Setup Volta and Node"

print_question "Install Node 20 via Volta?"
printf " ${BOLD_WHITE}(y/n)${RESET} "
REPLY="$(read_yn)"
printf "\n"

if [[ "$REPLY" == "Y" ]]; then
  volta install node@20
  print_success "Node 20 installed"
fi

if [[ $(brew list node) ]]; then
  brew unlink node
  print_notice "Homebrew-installed Node unlinked"
fi

# -- Neovim setup -------------------------------------------------


