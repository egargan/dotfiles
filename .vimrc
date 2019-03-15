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
" Enable line numbers
set number


" Syntax highlighting
syntax on

" Download despacio if not installed
silent ! [ -e ~/.vim/colors/despacio.vim ] || curl --create-dirs -o ~/.vim/colors/despacio.vim https://raw.githubusercontent.com/AlessandroYorba/Despacio/master/colors/despacio.vim

" Set despacio colour scheme with dark bg
let g:despacio_Midnight=1
colorscheme despacio


"" Rebindings ""
" 'nnoremap' - n: normal mode (not visual, insert etc.), nore: non-recursive map,
" other mappings to e.g. <C-J> do not map to <C-W><C-J>, map: map.

" Easier split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" 5-line up/down jumps
nnoremap <S-k> 5k
nnoremap <S-j> 5j


"" Plugins ""
" Don't forget to run :PlugInstall (todo: run PlugInstall in here only if
" some/all plugins aren't installed)

" Specify directory for vimplug plugins
call plug#begin('~/.vim/plugged')

" Code commenting - see :help nercommenter
Plug 'scrooloose/nerdcommenter'

" Initialise vimplug
call plug#end()

" Lets plugins configure themselves based on filetype, important for e.g. code
" commenting where filetype determines the comment string 
filetype plugin on

