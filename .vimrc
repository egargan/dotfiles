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

" Search files from wd. 'GitFiles' looks for tracked files, 'Files' looks everywhere.
nnoremap <C-T> :GitFiles<Enter>
nnoremap <S-T> :Files<Enter>

" Full text search from wd. Ditto 'GitRg' / 'Rg'.
nnoremap \ :GitRg<Enter>
nnoremap <Bar> :Rg<Enter>

" GitRg search for word under cursor
nnoremap <Leader>* :GitRg <C-r><C-w><Enter>

" Search open buffer names
nnoremap <Tab> :Buffers<Enter>

" Text search current buffer
nnoremap <Leader>s :BLines<Enter>

let rg_command = 'rg --column --line-number --no-heading --smart-case '

" Ensures Rg/GitRg don't match filenames shown in preview window
let preview_dict = { 'options':  '--delimiter : --nth 4..' }

command! -bang -nargs=* GitRg call fzf#vim#grep(rg_command
    \ .shellescape(<q-args>), 1, fzf#vim#with_preview(preview_dict), <bang>0)

command! -bang -nargs=* Rg call fzf#vim#grep(rg_command . ' --no-ignore-vcs '
    \ .shellescape(<q-args>), 1, fzf#vim#with_preview(preview_dict), <bang>0)


" -- prabirshrestha/vim-lsp --------------------------------------------------

" Show diagnostic message under cursor in status line
let g:lsp_diagnostics_echo_cursor = 1

" Enable 'W', 'E', etc. 'signs' in gutter
let g:lsp_signs_enabled = 1

" Highlight references to symbol under cursor
let g:lsp_highlight_references_enabled = 1

if executable('rust-analyzer')
  au User lsp_setup call lsp#register_server({
      \ 'name': 'rust-analyzer',
      \ 'cmd': {server_info->['rust-analyzer']},
      \ 'root_uri':{server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'Cargo.toml'))},
      \ 'whitelist': ['rust'],
      \ 'blacklist': [],
      \ 'workspace_config': {},
      \ 'semantic_highlight': {},
      \ })
  function! s:rust_analyzer_apply_source_change(context)
      let l:command = get(a:context, 'command', {})
      let l:workspace_edit = get(l:command['arguments'][0], 'workspaceEdit', {})
      if !empty(l:workspace_edit)
          call lsp#utils#workspace_edit#apply_workspace_edit(l:workspace_edit)
      endif
      let l:cursor_position = get(l:command['arguments'][0], 'cursorPosition', {})
      if !empty(l:cursor_position)
          call cursor(lsp#utils#position#lsp_to_vim('%', l:cursor_position))
      endif
  endfunction
  call lsp#register_command('rust-analyzer.applySourceChange', function('s:rust_analyzer_apply_source_change'))
endif

function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  setlocal signcolumn=yes
  if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
  nmap <buffer> gd <plug>(lsp-definition)
  nmap <buffer> <leader>rn <plug>(lsp-rename)
  nmap <buffer> [e <Plug>(lsp-previous-error)
  nmap <buffer> ]e <Plug>(lsp-next-error)
  nmap <buffer> [w <Plug>(lsp-previous-warning)
  nmap <buffer> ]w <Plug>(lsp-next-warning)
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

" Easier split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Larger split resizing
nnoremap <C-w>m <C-w>10<
nnoremap <C-w>/ <C-w>10>

" Speedy tab navigation
nnoremap ]t :tabnext<Enter>
nnoremap [t :tabprev<Enter>

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

" Delete everything between cursor and end of above line
noremap <C-j> :norm hvk$"_d<Enter>


" === Autocommands  ==========================================================

" Remove trailing whitespace on save
au BufWritePre * :%s/\s\+$//e

" === TODO ===================================================================

" - Make markdown editing prettier (need to add 'filetype-specific' area')
" - Rethink buffer management solution. fzf's :Buffers works OK, but I'd
"   prefer a solution where I only have to <Tab> then a buffer number, vs
"   <Tab> + number + <Enter>. It also occupies a lot of screen space.
