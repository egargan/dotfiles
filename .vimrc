"" General ""

syntax on                           " Syntax highlighting
set number                          " Line numbers
set hlsearch                        " Highlight strings matching searches

set expandtab                       " Converts existing tab chars to spaces on file open
set tabstop=4                       " How many spaces existing tabs are converted to
set softtabstop=4                   " Number of spaces inserted on tab press
set smarttab                        " If spaces already in line, only insert enough to meet tab width
set shiftwidth=4                    " Tab width used by 'smarttab', and by '>>'/'<<

set ttimeout                        " Enable timeouts for keycode seqs, ~lets us esc quicker from insert mode
set ttimeoutlen=50

set scrolloff=4                     " Always keep cursor >= 4 lines away from top and bottom of screen

set wildmenu                        " Bash-style filename tabbing
set wildmode=longest,list           " (on tab, complete to longest common path, or show options if not possible)
set wildignore=.git,*.swp,*/tmp/*

set laststatus=2                    " Always show status bar

set autoread                        " Re-read open files modified outside of vim

set undofile                        " Lave undo history to file
set undoreload=1000                 " Limit history to 1k lines
set undodir=~/.vim/undo             " Set loc for undo history
silent ! mkdir -p ~/.vim/undo       " mkdir if it doesn't exist

autocmd BufWritePre * :%s/\s\+$//e  " Remove trailing whitespace on save


"" Filetype Specific ""
" TODO markdown editing customisations - linebreak, map gj, gk, to j, k; etc.

if (expand('%:t') =~ '^COMMIT_')   " nonumber for git commit messages
    set nonumber
endif


"" Aesthetic ""

" Download colorscheme if not installed
silent ! [ -e ~/.vim/colors/tomorrow-night.vim ] ||
    \ curl --create-dirs -o ~/.vim/colors/tomorrow-night.vim
    \ https://raw.githubusercontent.com/chriskempson/tomorrow-theme/master/vim/colors/Tomorrow-Night.vim

colorscheme tomorrow-night


"" Remappings ""
" 'nnoremap' - n: normal mode (not visual, insert etc.),
" nore: non-recursive map, other mappings to e.g. <C-J> do not map to <C-W><C-J>
" TODO easier window resizing, e.g. resize 5 columns in one + allow repeated input

nnoremap <C-J> <C-W><C-J>           " Easier split navigation
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

noremap <C-t>k :tabr<cr>            " Easier tab navigation
noremap <C-t>j :tabl<cr>
noremap <C-t>h :tabp<cr>
noremap <C-t>l :tabn<cr>

noremap <C-t>e :tabnew<Space>       " Open / quit tabs
noremap <C-t>q :tabc

nnoremap <S-k> 5k                   " 5-line up/down jumps
nnoremap <S-j> 5j
vnoremap <S-k> 5k
vnoremap <S-j> 5j

nnoremap <S-h> 5h                   " 5-char jumps
nnoremap <S-l> 5l
vnoremap <S-h> 5h
vnoremap <S-l> 5l

nnoremap <leader>d "_d              " Cuts to black hole buffer
nnoremap <leader>x "_x

nnoremap * *``                      " Don't jump to next match when *ing
noremap <leader><leader> :noh<CR>   " Easy remove highlights over search matches

noremap <leader>r :%s/\<<C-r><C-w>\>//g<left><left>     " %s///g macro for word under cursor


"" Plugins ""

" Install vimplug if not already installed
if empty(glob('~/.vim/autoload/plug.vim'))
    silent ! curl --create-dirs -fLo ~/.vim/autoload/plug.vim \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

let plugins = []

call add(plugins, 'tpope/vim-commentary')       " Code commenting plugin

call add(plugins, 'itchyny/lightline.vim')      " Nice status line
set noshowmode                                  " Hide vanilla mode status
let g:lightline = {
\   'colorscheme' : 'Tomorrow_Night'
\}

call add(plugins, 'airblade/vim-gitgutter')     " Show git diff symbols in gutter
set updatetime=1000                             " Time plugins take to respond to changes, 4s default
highlight link GitGutterAdd diffAdded           " Link highlight groups to existing ones in colorscheme
highlight link GitGutterChange Function         " No 'diffChange' group, so just use arbitrary blue group
highlight link GitGutterDelete diffRemoved

call add(plugins, 'tpope/vim-surround')         " Easy surrounding quotes, tags, parens, etc.

let plugin_dir = '~/.vim/plugged'    " Specify directory for vimplug plugins
call plug#begin(plugin_dir)

for plugin in plugins
    let plugin_name = split(plugin, '/')[-1]

    " TODO fix - this isn't working all the time
    " If plug isn't installed, manually PlugInstall after vim startup (autocmd VimEnter,
    " http://learnvimscriptthehardway.stevelosh.com/chapters/12.html#autocommand-structure)
    if empty(glob(plugin_dir . '/' . plugin_name))
        autocmd VimEnter * execute 'PlugInstall --sync ' . plugin_name . '| source ~/.vimrc'
    endif

    Plug plugin    " Apply plugin to current session
endfor

call plug#end()    " Initialise vimplug

" Lets plugins configure themselves based on filetype, important for e.g. code
" commenting where filetype determines the comment string
filetype plugin on
