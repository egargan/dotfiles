"" General

syntax on                           " Syntax highlighting
set number                          " Line numbers
set hlsearch                        " Highlight strings matching searches

set expandtab                       " Always enter spaces on <Tab>
set softtabstop=2                   " How many spaces are entered on <Tab>
set shiftwidth=2                    " Tab width used by 'smarttab', and '>>'/'<<
set smarttab                        " If spaces already in line, only insert enough to meet tab width
set shiftround                      " Round '>>/'<<' indents to nearest tabstop

set ttimeout                        " Enable timeouts for keycode seqs, ~lets us esc quicker from i mode
set ttimeoutlen=50

set scrolloff=4                     " Always keep cursor >= 4 lines away from top and bottom of screen
set linebreak                       " Don't wrap lines in the middle of words
set colorcolumn=80                  " Show line length boundary at line 80
set laststatus=2                    " Always show status bar
set cursorline                      " Highlight cursor's line

set wildmenu                        " Bash-style filename tabbing
set wildmode=longest,list           " (on tab, complete to longest common path, or show options if not possible)
set wildignore=.git,*.swp,*/tmp/*

set complete-=i                     " Don't look in included src files for word completion

set autoread                        " Re-read open files modified outside of vim

set undofile                        " Lave undo history to file
set undoreload=1000                 " Limit history to 1k lines
set undodir=~/.vim/undo             " Set loc for undo history

" mkdir if it doesn't exist
silent ! [ -d ~/.vim/undo ] || mkdir ~/.vim/undo

set incsearch                       " Perform searches as they're typed
set ignorecase                      " Ignore case in searches by default
set smartcase                       " Enable case sensitivity if capital entered

set relativenumber                  " Line numbers are relative to cursor's line

set formatoptions-=o                " Disable comment block continuation on o/O
set formatoptions+=r                " But enable on <Enter> in insert mode

set shortmess-=S                    " Show match counter when searching

au BufWritePre * :%s/\s\+$//e       " Remove trailing whitespace on save

let g:netrw_liststyle=3             " Set default netrw liststyle to 'tree' mode


"" Filetype Specific ""

" nonumber for git commit messages
if (expand('%:t') =~ '^COMMIT_')
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

" Easier split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Larger split resizing
nnoremap <C-w>m <C-w>10<
nnoremap <C-w>/ <C-w>10>

" Open / quit tabs
noremap <C-t>e :tabnew<Space>
noremap <C-t>q :tabc

" 5-line up/down jumps
nmap <S-k> 5k
nmap <S-j> 5j
vmap <S-k> 5k
vmap <S-j> 5j

" Cuts to black hole buffer
nnoremap <leader>d "_d
nnoremap <leader>x "_x
vnoremap <leader>d "_d
vnoremap <leader>x "_x

" Stop j/k working linewise
noremap j gj
noremap k gk

" Don't jump to next match when *ing
nnoremap * *``

" Easy remove highlights over search matches
noremap <Bs> :noh<CR>

" s///g macro for word under cursor - applies to whole file in
" normal mode, or to selection only in visual mode
nnoremap <leader>r :%s/\<<C-r><C-w>\>//g<left><left>
vnoremap <leader>r :s/\<<C-r><C-w>\>//g<left><left>

" Join current and below lines (should be <S-j>, but I've remapped this)
noremap <C-j> :join!<Enter>

" Macro for netrw file explorer, displayed NERDTree style
nnoremap <Leader>e :Lex <Bar> vertical resize 35<Enter>


"" Plugins ""

" Install vimplug if not already installed
if empty(glob('~/.vim/autoload/plug.vim'))
    silent ! curl --create-dirs -fLo ~/.vim/autoload/plug.vim
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

let plugins = []

call add(plugins, 'tpope/vim-commentary')       " Code commenting plugin

call add(plugins, 'itchyny/lightline.vim')      " Nice status line
set noshowmode                                  " Hide vanilla mode status
let g:lightline = {
\   'colorscheme' : 'Tomorrow_Night',
\}

call add(plugins, 'airblade/vim-gitgutter')     " Show git diff symbols in gutter
set updatetime=1000                             " Time plugins take to respond to changes, 4s default
highlight link GitGutterAdd diffAdded           " Link highlight groups to existing ones in colorscheme
highlight link GitGutterChange Function         " No 'diffChange' group, so just use arbitrary blue group
highlight link GitGutterDelete diffRemoved

call add(plugins, 'tpope/vim-surround')         " Easy surrounding quotes, tags, parens, etc.

call add(plugins, 'junegunn/vim-easy-align')    " Easy alignment for rows of words, vars, etc.
nmap ga <Plug>(EasyAlign)
xmap ga <Plug>(EasyAlign)

" TODO: potentially installing duplicate fzf if already installed e.g. via
" dnf, check 'hash fzf' before installing?
call add(plugins, 'junegunn/fzf')               " Fuzzy file finding (CLI package)
call add(plugins, 'junegunn/fzf.vim')           " Vim wrapper for CL fzf
nnoremap <Leader>f :Files<Enter>


let plugin_dir = '~/.vim/plugged'    " Specify directory for vimplug plugins
let plugin_names_string = ''

call plug#begin(plugin_dir)

for plugin in plugins
    Plug plugin    " Apply plugin to current session

    let plugin_name = split(plugin, '/')[-1]

    if empty(glob(plugin_dir . '/' . plugin_name))
        let plugin_names_string = plugin_names_string . ' ' . plugin_name
    endif
endfor

" If any plugs not installed, manually PlugInstall on vim startup
if plugin_names_string != ''
    autocmd VimEnter * execute 'PlugInstall --sync ' . plugin_names_string . '| source ~/.vimrc'
endif

call plug#end()    " Initialise vimplug

" Lets plugins configure themselves based on filetype, important for e.g. code
" commenting where filetype determines the comment string
filetype plugin on
