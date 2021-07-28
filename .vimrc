let mapleader=" "                   " Set <Leader> to space - '\' is too awkward

" == Plugins =================================================================

" Install vimplug if not already installed
if empty(glob('~/.vim/autoload/plug.vim'))
    silent ! curl --create-dirs -fLo ~/.vim/autoload/plug.vim
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

let plugin_dir = '~/.vim/plugged'

call plug#begin(plugin_dir)

" ----------------------------------------------------------------------------

" Code commenting plugin
Plug 'tpope/vim-commentary'

" Pretty status line
Plug 'itchyny/lightline.vim'

" Show git diff symbols in gutter
Plug 'airblade/vim-gitgutter'

" Easy surrounding quotes, tags, parens, etc.
Plug 'tpope/vim-surround'

" Easy alignment for rows of words, vars, etc.
Plug 'junegunn/vim-easy-align'

" Fuzzy file finding (CLI package + vim wrapper)
" TODO: potentially installing duplicate fzf if already installed e.g. via
" dnf, check 'hash fzf' before installing?
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Language server framework
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'

" YAML formatting + highlighting
Plug 'mrk21/yaml-vim'

" Indentation indicators
Plug 'Yggdroot/indentLine'

" Filesystem explorer
Plug 'preservim/nerdtree'

" Svelte language support
Plug 'leafOfTree/vim-svelte-plugin', { 'for': ['svelte'] }

" SCSS syntax support
Plug 'cakebaker/scss-syntax.vim', { 'for': ['scss'] }

" Typescript langauge support
Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }

" Commands for closing buffers without closing windows
Plug 'moll/vim-bbye'

" In-vim Git handiness
Plug 'tpope/vim-fugitive'


" ----------------------------------------------------------------------------

let plugin_names_string = ''

" Create list of plugged plugins that aren't installed
for plugin_name in g:plugs_order
    if empty(glob(plugin_dir . '/' . plugin_name))
        let plugin_names_string = plugin_names_string . ' ' . plugin_name
    endif
endfor

" If any plugs not installed, manually PlugInstall on vim startup
if plugin_names_string != ''
    autocmd VimEnter * execute 'PlugInstall --sync ' . plugin_names_string . '| source ~/.vimrc'
endif

 " Initialise vimplug
call plug#end()


" == Plugin Settings + Mappings ==============================================

" -- itchyny/lightline -------------------------------------------------------

" Hide vanilla mode status
set noshowmode

let g:lightline = {
\   'colorscheme' : 'Tomorrow_Night',
\   'active': {
\     'left': [ [ 'mode', 'paste' ],
\                [ 'readonly', 'filename' ],
\                [ 'lastbuf' ]],
\     'right': [ [ 'lineinfo' ],
\                [ 'percent' ],
\                [ 'filetype' ] ]
\   },
\   'component_function': {
\     'filename': 'LightlineFilename',
\     'lastbuf': 'LightlineLastBuffer'
\   },
\}

" Returns Lightline's usual 'filename' string, but without the '|' separating
" the filename and the modified indicator
function! LightlineFilename()
  let filename = expand('%:t') !=# '' ? expand('%:t') : '[No Name]'
  return filename . (&modified ? ' +' : '')
endfunction

" Returns the filename of the 'alternate' buffer, essentially that
" most-recently opened
" TODO: can we fix #'s behavior so it doesn't refer to deleted buffers?
function! LightlineLastBuffer()
  return bufname('#')
endfunction

" Shortcut for opening the most-recently-open buffer
nnoremap <silent> <S-Tab> :execute bufnr('#') == -1 ? '' : 'b' . bufnr('#')<Enter>

" -- airblade/vim-gitgutter --------------------------------------------------

" Time plugins take to respond to changes, 4s default
set updatetime=1000

" Link highlight groups to existing ones in colorscheme
highlight link GitGutterAdd diffAdded

" No 'diffChange' group, so just use arbitrary blue group
highlight link GitGutterChange Function
highlight link GitGutterDelete diffRemoved

" -- junegunn/vim-easy-align -------------------------------------------------

nmap ga <Plug>(EasyAlign)
xmap ga <Plug>(EasyAlign)

" -- junegunn/fzf ------------------------------------------------------------

" Returns the currently-selected 'dir node' if NERDTree is focused, '.' otherwise.
function! GetSearchRootDir()
  if getbufvar(bufnr(), '&filetype') == 'nerdtree' && has_key(g:NERDTreeDirNode.GetSelected(), 'path')
    return g:NERDTreeDirNode.GetSelected().path.str()
  else
    return '.'
  endif
endfunction

" Search files from wd. 'GitFiles' looks for tracked files, 'Files' looks everywhere.
nnoremap <C-T> :silent execute 'GitFiles ' . GetSearchRootDir()<Enter>
nnoremap <S-T> :silent execute 'Files ' . GetSearchRootDir()<Enter>

" Full text search from wd. Ditto 'GitRg' / 'Rg'.
nnoremap \ :GitRg<Enter>
nnoremap <Bar> :Rg<Enter>

" GitRg search for word under cursor
nnoremap <Leader>* :StarRg <C-r><C-w><Enter>

" Search open buffer names
nnoremap <Tab> :Buffers<Enter>

" Text search current buffer
nnoremap <Leader>s :BLines<Enter>

" Enable FZF search history
let g:fzf_history_dir = '~/.local/share/vim_fzf_history'

" TODO: play with these colours
let rg_command = 'rg --line-number --no-heading --smart-case --color=always '
  \. '--colors "path:fg:105,128,161" --colors "line:fg:74,85,120" '

" Returns config for 'fzf#vim#with_preview' function, telling it where to
" search from, and to not match filenames in Rg output.
function! GetRgOpts()
  return { 'dir': GetSearchRootDir(), 'options': '--delimiter : --nth 3.. --bind="CTRL-p:toggle-preview"' }
endfunction

" Returns the above config with an extra 'query' option, the initial query string
function! GetStarRgOpts(query)
  let rg_opts = GetRgOpts()
  let rg_opts['options'] = rg_opts['options'] . ' --query ''' . a:query . ''''
  return rg_opts
endfunction

" TODO: have this not fail when there aren't any files to search
command! -bang -nargs=* GitRg call fzf#vim#grep(rg_command
  \ .shellescape(<q-args>), 1, fzf#vim#with_preview(GetRgOpts()), <bang>0)

command! -bang -nargs=* Rg call fzf#vim#grep(rg_command . ' --no-ignore-vcs '
  \ .shellescape(<q-args>), 1, fzf#vim#with_preview(GetRgOpts()), <bang>0)

" TODO: why do we need the 'shellescape()' bit for this to work? It just
" returns '', but trying to just concat '' to rg_command doesn't work??
command! -bang -nargs=* StarRg call fzf#vim#grep(rg_command
  \ .shellescape(''), 1, fzf#vim#with_preview(GetStarRgOpts(<q-args>)), <bang>0)


" -- prabirshrestha/vim-lsp + friends ----------------------------------------

" Show diagnostic message under cursor in status line
let g:lsp_diagnostics_echo_cursor = 1

" Enable 'W', 'E', etc. 'signs' in gutter
let g:lsp_signs_enabled = 1

" Highlight references to symbol under cursor
let g:lsp_highlight_references_enabled = 1

" Log LSP's doings for when things go wrong
let g:lsp_log_file = expand('~/.vim-lsp.log')

let g:lsp_settings_servers_dir = '~/.vim/lsp/servers'

function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  setlocal signcolumn=yes
  if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
  nnoremap <buffer> gd <plug>(lsp-definition)
  nnoremap <buffer> <leader>r <plug>(lsp-rename)
  nnoremap <buffer> [e <Plug>(lsp-previous-error)
  nnoremap <buffer> ]e <Plug>(lsp-next-error)
  nnoremap <buffer> [w <Plug>(lsp-previous-warning)
  nnoremap <buffer> ]w <Plug>(lsp-next-warning)
  nnoremap <buffer> [d <Plug>(lsp-previous-diagnostic)
  nnoremap <buffer> ]d <Plug>(lsp-next-diagnostic)
  inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
  inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
  inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" -- Yggdroot/indentLine -----------------------------------------------------

" Disable indent lines by default
let g:indentLine_enabled = 0

nmap <Leader>i :IndentLinesToggle<Enter>

" -- preservim/nerdtree ------------------------------------------------------

map <Leader>e :NERDTreeToggle<CR>

" Navigates to % in NERDTree, opening it if not already open
map <Leader>5 :NERDTreeFind<CR>

" Disable NERDTree's <S-T> mapping, which we use for :Files
let g:NERDTreeMapOpenInTabSilent=0

" -- leafOfTree/vim-svelte-plugin --------------------------------------------

" Enable optional language support
let g:vim_svelte_plugin_use_typescript=1
let g:vim_svelte_plugin_use_sass=1

" -- moll/vim-bbye -----------------------------------------------------------

" Hotkey friendly delete buffer
nnoremap - :Bd<Enter>


" === General Settings  ======================================================

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
set hidden                          " Don't require :w when leaving modified buffers

set undofile                        " Lave undo history to file
set undoreload=1000                 " Limit history to 1k lines
set undodir=~/.vim/undo             " Set loc for undo history

 " create undo dir if !exists
silent ! [ -d ~/.vim/undo ] || mkdir ~/.vim/undo

set directory=~/.vim/swap//         " Keep swaps in home dir (trailing '//' creates full-path-name .swps)

 " create swap dir if !exists
silent ! [ -d ~/.vim/swap ] || mkdir ~/.vim/swap

set incsearch                       " Perform searches as they're typed
set ignorecase                      " Ignore case in searches by default
set smartcase                       " Enable case sensitivity if capital entered
set shortmess-=S                    " Show match counter when searching

set relativenumber                  " Line numbers are relative to cursor's line

set formatoptions-=r                " Disable comment block continuation on <Enter>
set formatoptions-=o                " Disable comment block continuation on o/O

let g:netrw_liststyle=3             " Set default netrw liststyle to 'tree' mode


" === Theme ==================================================================

" Download colorscheme if not installed
silent ! [ -e ~/.vim/colors/tomorrow-night.vim ] ||
    \ curl --create-dirs -o ~/.vim/colors/tomorrow-night.vim
    \ https://raw.githubusercontent.com/chriskempson/tomorrow-theme/master/vim/colors/Tomorrow-Night.vim

colorscheme tomorrow-night


" === General Mappings  ======================================================

" Larger split resizing
nnoremap <C-w>m <C-w>10<
nnoremap <C-w>/ <C-w>10>

" Speedy tab navigation
nnoremap ]t :tabnext<Enter>
nnoremap [t :tabprev<Enter>

" Faster new tab
nnoremap ]T :tabnew<Enter>

" 5-line up/down jumps
noremap <S-k> 5k
noremap <S-j> 5j

" Cuts to black hole buffer
noremap <leader>d "_d
noremap <leader>x "_x

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

" Delete everything between cursor and end of above line
noremap <C-j> :norm "_d0kgJ"<Enter>


" === Autocommands  ==========================================================

" Remove trailing whitespace on save
au BufWritePre * :%s/\s\+$//e


" === Host-specific config ===================================================

if filereadable(expand('~/.vimrc.private'))
  source ~/.vimrc.private
endif


" === TODO ===================================================================

" - Make markdown editing prettier (need to add 'filetype-specific' area')
" - Rethink buffer management solution. fzf's :Buffers works OK, but I'd
"   prefer a solution where I only have to <Tab> then a buffer number, vs
"   <Tab> + number + <Enter>. It also occupies a lot of screen space.
