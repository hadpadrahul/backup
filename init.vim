" ==================================================
" Neovim configuration
" Personal + Server safe (SSH / TTY compatible)
" No plugins, learning-focused, daily driver
" ==================================================

"--------------------------------------------------
" Startup & filetypes
"--------------------------------------------------
filetype plugin indent on

" Speed up Lua module loading (Neovim 0.9+)
if exists('*luaeval')
  silent! lua vim.loader.enable()
endif

"--------------------------------------------------
" UI & visibility (TTY-safe)
"--------------------------------------------------
set number
set relativenumber
set cursorline
set nowrap

set scrolloff=8
set sidescrolloff=8

set signcolumn=yes
set showcmd

if has('termguicolors')
  set termguicolors
endif

" Safe builtin colorscheme
silent! colorscheme habamax

"--------------------------------------------------
" Indentation
"--------------------------------------------------
set tabstop=4
set shiftwidth=4
set expandtab

set autoindent
set smartindent

"--------------------------------------------------
" Search
"--------------------------------------------------
set ignorecase
set smartcase
set incsearch
set hlsearch

"--------------------------------------------------
" Editing behavior
"--------------------------------------------------
set hidden
set confirm
set backspace=indent,eol,start

set updatetime=200
set lazyredraw

set ttimeout
set ttimeoutlen=50

"--------------------------------------------------
" Files & undo (SERVER SAFE)
"--------------------------------------------------
set noswapfile
set nobackup
set nowritebackup

set undofile
set undolevels=2000

" Undo directory (must be string)
let s:undodir = stdpath('data') . '/undo'
let &undodir = s:undodir

if !isdirectory(s:undodir)
  call mkdir(s:undodir, 'p')
endif

"--------------------------------------------------
" Clipboard
"--------------------------------------------------
set clipboard=unnamedplus

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
set listchars=tab:>-,trail:.,nbsp:+

"--------------------------------------------------
" Leader key
"--------------------------------------------------
let mapleader=" "

set timeout
set timeoutlen=800

"--------------------------------------------------
" Keymaps
"--------------------------------------------------
nnoremap <silent> <Esc><Esc> :nohlsearch<CR>

nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>wq :wq<CR>
nnoremap <leader>Q :q!<CR>

nnoremap n nzzzv
nnoremap N Nzzzv

vnoremap < <gv
vnoremap > >gv

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

inoremap jk <Esc>

"--------------------------------------------------
" Toggles
"--------------------------------------------------
nnoremap <leader>n :set relativenumber!<CR>
nnoremap <leader>c :set cursorline!<CR>
nnoremap <leader>l :set list!<CR>

"--------------------------------------------------
" Commenting (no plugins)
"--------------------------------------------------
nnoremap <leader>/ :lua << EOF
local cs = vim.bo.commentstring
if cs == "" then return end
local comment = cs:gsub("%%s", "")
local line = vim.api.nvim_get_current_line()
if line:match("^%s*" .. vim.pesc(comment)) then
  line = line:gsub("^%s*" .. vim.pesc(comment) .. "%s?", "", 1)
else
  line = comment .. " " .. line
end
vim.api.nvim_set_current_line(line)
EOF<CR>

vnoremap <leader>/ :lua << EOF
local cs = vim.bo.commentstring
if cs == "" then return end
local comment = cs:gsub("%%s", "")
local start = vim.fn.line("'<")
local finish = vim.fn.line("'>")
for i = start, finish do
  vim.fn.setline(i, comment .. " " .. vim.fn.getline(i))
end
EOF<CR>

"--------------------------------------------------
" Quickfix navigation
"--------------------------------------------------
nnoremap ]q :cnext<CR>
nnoremap [q :cprev<CR>
nnoremap <leader>qo :copen<CR>
nnoremap <leader>qc :cclose<CR>

"--------------------------------------------------
" Terminal sanity
"--------------------------------------------------
tnoremap <Esc> <C-\><C-n>
tnoremap jk <C-\><C-n>

"--------------------------------------------------
" Autocommands
"--------------------------------------------------
augroup YankHighlight
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank({ timeout = 150 })
augroup END

augroup ResizeSplits
  autocmd!
  autocmd VimResized * wincmd =
augroup END

"--------------------------------------------------
" OSC52 clipboard (SSH support)
"--------------------------------------------------
if exists('$SSH_CONNECTION') || exists('$SSH_TTY')
  silent! lua << EOF
  local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
  if ok then
    vim.g.clipboard = {
      name = "OSC 52",
      copy = {
        ["+"] = osc52.copy("+"),
        ["*"] = osc52.copy("*"),
      },
      paste = {
        ["+"] = osc52.paste("+"),
        ["*"] = osc52.paste("*"),
      },
    }
  end
EOF
endif

" ==================================================
" End of configuration
" ==================================================
