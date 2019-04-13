" Converts existing tab chars to spaces on file open
set expandtab
" How many spaces existing tabs are converted to
set tabstop=4
" Number of spaces inserted on tab press
set softtabstop=4
" If spaces already exist in line, only insert spaces needed to meet tab width
set smarttab
" Tab width used by 'smarttab', and by '>>'/'<<'
set shiftwidth=4

" Enable line numbers (except for git commit messages)
if (expand('%:t') !~ '^COMMIT_')
    set number
endif


"" Rebindings ""

" 'nnoremap' - n: normal mode (not visual, insert etc.), nore: non-recursive map, other mappings to e.g. <C-J> do not map to <C-W><C-J>, map: map.
" Easier split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" 5-line up/down jumps
nnoremap <S-k> 5k
nnoremap <S-j> 5j
vnoremap <S-k> 5k
vnoremap <S-j> 5j

"" Customisation ""

" Syntax highlighting
syntax on

" Download despacio if not installed
silent ! [ -e ~/.vim/colors/tomorrow-night.vim ] || curl --create-dirs -o ~/.vim/colors/tomorrow-night.vim https://raw.githubusercontent.com/chriskempson/tomorrow-theme/master/vim/colors/Tomorrow-Night.vim 
colorscheme tomorrow-night

" Always show status bar
set laststatus=2


"" Plugins ""

" Install vimplug if not already installed
if empty(glob('~/.vim/autoload/plug.vim'))
    silent ! curl --create-dirs -fLo ~/.vim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

let plugins = []

call add(plugins, 'scrooloose/nerdcommenter')

" Count files in .vim/plugged directory
let num_plugged = len(split(globpath('~/.vim/plugged/', '*'), '\n'))

" PlugInstall if missing plugins - 'VimEnter' -> plugins installed after .vimrc is read
if num_plugged < len(plugins)
    autocmd VimEnter * PlugInstall --sync | source ~/.vimrc
endif

" Specify directory for vimplug plugins
call plug#begin('~/.vim/plugged')

for plugin in plugins
    Plug plugin
endfor

" Initialise vimplug
call plug#end()

" Lets plugins configure themselves based on filetype, important for e.g. code
" commenting where filetype determines the comment string
filetype plugin on
