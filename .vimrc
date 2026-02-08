" ==================================================
" Vim configuration (.vimrc)
" Personal + Server safe (SSH / TTY compatible)
" No plugins, learning-focused, daily driver
" ==================================================

"--------------------------------------------------
" Always start in 'nocompatible' mode (better defaults)
"--------------------------------------------------
set nocompatible

"--------------------------------------------------
" Filetype detection and indent plugins
"--------------------------------------------------
filetype plugin indent on
syntax on

"--------------------------------------------------
" UI & visibility
"--------------------------------------------------
" Show absolute + relative line numbers
set number
set relativenumber

" Highlight current line
set cursorline

" Don't wrap long lines
set nowrap

" Keep context visible when scrolling
set scrolloff=8
set sidescrolloff=8

" Always show sign column
if exists('+signcolumn')
  set signcolumn=yes
endif

" Show partially typed commands
set showcmd

" Enable true colors if supported
if has("termguicolors")
  set termguicolors
endif

" Try a safe colorscheme
silent! colorscheme habamax
" Fallback if not found
if !exists("g:colors_name")
  silent! colorscheme desert
endif

"--------------------------------------------------
" Indentation
"--------------------------------------------------
set tabstop=4        " Visual width of a TAB
set shiftwidth=4     " Indents use 4 spaces
set expandtab        " Convert TABs → spaces

" Keep indentation smart
set autoindent
set smartindent

"--------------------------------------------------
" Search behavior
"--------------------------------------------------
" Case insensitive unless uppercase used
set ignorecase
set smartcase

" Show matches while typing
set incsearch

" Highlight search results
set hlsearch

"--------------------------------------------------
" Editing behavior
"--------------------------------------------------
" Allow switching buffers without saving
set hidden

" Ask before destructive actions
set confirm

" Better backspace in insert mode
set backspace=indent,eol,start

" Faster redraws for SSH
set updatetime=200
set lazyredraw

" Mouse support (useful in terminals too)
set mouse=a

" Faster key response (important over SSH)
set ttimeout
set ttimeoutlen=50

"--------------------------------------------------
" File handling & undo
"--------------------------------------------------
" Turn off swap / backup files
set noswapfile
set nobackup
set nowritebackup

" Persistent undo
if has("persistent_undo")
  set undofile
  set undolevels=2000

  " Store undo files here
  let s:undo_dir = expand("~/.vim/undo//")
  if !isdirectory(s:undo_dir)
    call mkdir(s:undo_dir, "p")
  endif
  let &undodir = s:undo_dir
endif

"--------------------------------------------------
" Clipboard
"--------------------------------------------------
" Use system clipboard if available
if has("clipboard")
  set clipboard=unnamedplus
endif

"--------------------------------------------------
" Splits
"--------------------------------------------------
set splitright
set splitbelow

"--------------------------------------------------
" Command-line completion
"--------------------------------------------------
set wildmenu
set wildmode=longest:full,full

"--------------------------------------------------
" Whitespace visibility
"--------------------------------------------------
set list
set listchars=tab:→\ ,trail:·,nbsp:␣

"--------------------------------------------------
" Leader key
"--------------------------------------------------
let mapleader=" "
set timeout
set timeoutlen=800

"--------------------------------------------------
" Keymaps
"--------------------------------------------------

" Clear search highlight quickly
nnoremap <silent> <Esc><Esc> :nohlsearch<CR>

" Save / quit shortcuts
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>wq :wq<CR>
nnoremap <leader>Q :q!<CR>

" Keep search results centered
nnoremap n nzzzv
nnoremap N Nzzzv

" Maintain selection after indenting
vnoremap < <gv
vnoremap > >gv

" Easy window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Fast escape from insert mode
inoremap jk <Esc>

"--------------------------------------------------
" Toggles (learning helpers)
"--------------------------------------------------
" Toggle relative numbers
nnoremap <leader>n :set relativenumber!<CR>

" Toggle cursorline
nnoremap <leader>c :set cursorline!<CR>

" Toggle whitespace visibility
nnoremap <leader>l :set list!<CR>

"--------------------------------------------------
" Commenting (no plugins)
"--------------------------------------------------

" Toggle comment on current line
function! ToggleCommentLine()
  " If there’s no comment format, skip
  if &commentstring == ''
    return
  endif

  let l:comment = substitute(&commentstring, '%s', '', '')
  let l:line = getline('.')

  if l:line =~ '^\s*' . escape(l:comment, '\/.*$^~[]')
    " Uncomment
    let l:new = substitute(l:line, '^\s*' . escape(l:comment, '\/.*$^~[]') . '\s\?', '', '')
  else
    " Comment
    let l:new = l:comment . ' ' . l:line
  endif

  call setline('.', l:new)
endfunction

nnoremap <leader>/ :call ToggleCommentLine()<CR>

" Comment visual selection
function! CommentVisual()
  if &commentstring == ''
    return
  endif

  let l:comment = substitute(&commentstring, '%s', '', '')
  for lnum in range(line("'<"), line("'>"))
    call setline(lnum, l:comment . ' ' . getline(lnum))
  endfor
endfunction

vnoremap <leader>/ :<C-u>call CommentVisual()<CR>

"--------------------------------------------------
" Quickfix navigation
"--------------------------------------------------
nnoremap ]q :cnext<CR>
nnoremap [q :cprev<CR>
nnoremap <leader>qo :copen<CR>
nnoremap <leader>qc :cclose<CR>

"--------------------------------------------------
" Terminal sanity (Vim 8+ only)
"--------------------------------------------------
if has("terminal")
  tnoremap <Esc> <C-\><C-n>
  tnoremap jk  <C-\><C-n>
endif

"--------------------------------------------------
" Autocommands
"--------------------------------------------------
" Equalize splits on window resize
augroup ResizeSplits
  autocmd!
  autocmd VimResized * wincmd =
augroup END

" ==================================================
" End of configuration
" ==================================================
