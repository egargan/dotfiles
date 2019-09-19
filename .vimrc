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

" Enable timeouts for keycode sequences, basically lets us more quickly esc from insert mode
set ttimeout
set ttimeoutlen=50


"" Rebindings ""

" 'nnoremap' - n: normal mode (not visual, insert etc.), nore: non-recursive map, other mappings to e.g. <C-J> do not map to <C-W><C-J>
" Easier split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Easier tab navigation
noremap <C-t>k :tabr<cr>
noremap <C-t>j :tabl<cr>
noremap <C-t>h :tabp<cr>
noremap <C-t>l :tabn<cr>

" Open / quit tabs
noremap <C-t>e :tabnew<Space>
noremap <C-t>q :tabc

" 5-line up/down jumps
nnoremap <S-k> 5k
nnoremap <S-j> 5j
vnoremap <S-k> 5k
vnoremap <S-j> 5j

" 5-char jumps
nnoremap <S-h> 5h
nnoremap <S-l> 5l
vnoremap <S-h> 5h
vnoremap <S-l> 5l

" Cuts to black hole buffer
nnoremap <leader>d "_d
nnoremap <leader>x "_x

" Bash-style filename tabbing
set wildmenu
" (on tab, complete to longest common path, or show options if not possible)
set wildmode=longest,list
set wildignore=.git,*.swp,*/tmp/*

" Unhighlight searches with enter
nnoremap <CR> :noh<CR>

" TODO easier window resizing, e.g. resize 5 columns in one + allow repeated input


"" Customisation ""

" Syntax highlighting
syntax on

" Download colorscheme if not installed
silent ! [ -e ~/.vim/colors/tomorrow-night.vim ] || curl --create-dirs -o ~/.vim/colors/tomorrow-night.vim https://raw.githubusercontent.com/chriskempson/tomorrow-theme/master/vim/colors/Tomorrow-Night.vim
" gruvbox instead? looks nice..
colorscheme tomorrow-night

" Always show status bar
set laststatus=2

" Enable line numbers (except for git commit messages)
if (expand('%:t') !~ '^COMMIT_')
    set number
endif


"" Plugins ""

" Install vimplug if not already installed
if empty(glob('~/.vim/autoload/plug.vim'))
    silent ! curl --create-dirs -fLo ~/.vim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

let plugins = []

" Code commenting plugin
call add(plugins, 'scrooloose/nerdcommenter')

" Nice status line
" TODO add git branch name?
" TODO fix no colours bug when PlugInstall-ing any plugin?
call add(plugins, 'itchyny/lightline.vim')
let g:lightline  = { 'colorscheme' : 'Tomorrow_Night' }
" Hide vanilla mode status
set noshowmode

" Show git diff symbols in gutter
call add(plugins, 'airblade/vim-gitgutter')
" Decrease time plugins take to respond to changes, from 4s default
set updatetime=1000
" Link highlight groups to existing ones in colorscheme
" (gitgutter's default links don't exist in tomorrow-night, but these do)
highlight link GitGutterAdd diffAdded
" No 'diffChange' group, so just use arbitrary blue-coloured group instead
highlight link GitGutterChange Function
highlight link GitGutterDelete diffRemoved


" Specify directory for vimplug plugins
let plugin_dir = '~/.vim/plugged'
call plug#begin(plugin_dir)

for plugin in plugins
    let plugin_name = split(plugin, '/')[-1]

    " If plug isn't installed, manually PlugInstall after vim startup (autocmd VimEnter,
    " http://learnvimscriptthehardway.stevelosh.com/chapters/12.html#autocommand-structure)
    if empty(glob(plugin_dir . '/' . plugin_name))
        autocmd VimEnter * execute 'PlugInstall --sync ' . plugin_name . '| source ~/.vimrc'
    endif

    " Apply plugin to current session
    Plug plugin
endfor

" Initialise vimplug
call plug#end()

" Lets plugins configure themselves based on filetype, important for e.g. code
" commenting where filetype determines the comment string
filetype plugin on
