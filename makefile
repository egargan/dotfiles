stowed_dirs = bin git neovim zsh tmux

all:
	stow --verbose --target=$$HOME $(stowed_dirs)
delete:
	stow --verbose --target=$$HOME --delete $(stowed_dirs)
