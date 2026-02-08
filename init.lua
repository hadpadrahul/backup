-- ==================================================
-- Neovim configuration
-- Personal + Server safe (SSH / TTY compatible)
-- No plugins, learning-focused, daily driver
-- ==================================================

-----------------------------------------------------
-- Startup & filetypes
-----------------------------------------------------
-- Enable filetype detection, plugins, indentation
vim.cmd("filetype plugin indent on")

-- Speed up Lua module loading (Neovim 0.9+)
pcall(vim.loader.enable)

-----------------------------------------------------
-- UI & visibility (TTY-safe)
-----------------------------------------------------
-- Line numbers (absolute + relative)
vim.opt.number = true
vim.opt.relativenumber = true

-- Highlight current line (can be toggled)
vim.opt.cursorline = true

-- Do not wrap long lines (logs, configs)
vim.opt.wrap = false

-- Keep context visible while scrolling
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Prevent text shifting when signs appear
vim.opt.signcolumn = "yes"

-- Show partially typed commands
vim.opt.showcmd = true

-- Enable true color only if supported
if vim.fn.has("termguicolors") == 1 then
  vim.opt.termguicolors = true
end

-- Safe builtin colorscheme (never errors)
pcall(vim.cmd.colorscheme, "habamax")

-----------------------------------------------------
-- Indentation (language-agnostic)
-----------------------------------------------------
-- 4 spaces, no hard tabs
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Smart indentation
vim.opt.autoindent = true
vim.opt.smartindent = true

-----------------------------------------------------
-- Search behavior
-----------------------------------------------------
-- Case-insensitive unless uppercase used
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Incremental search
vim.opt.incsearch = true

-- Highlight matches (easy to clear)
vim.opt.hlsearch = true

-----------------------------------------------------
-- Editing behavior
-----------------------------------------------------
-- Allow buffer switching without saving
vim.opt.hidden = true

-- Ask before destructive actions
vim.opt.confirm = true

-- Modern backspace behavior
vim.opt.backspace = { "indent", "eol", "start" }

-- Faster UI updates
vim.opt.updatetime = 200

-- Reduce redraws (important over SSH)
vim.opt.lazyredraw = true

-- Faster key recognition (high latency)
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 50

-----------------------------------------------------
-- Files & undo (SERVER SAFE)
-----------------------------------------------------
-- Disable swap / backup files
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

-- Persistent undo
vim.opt.undofile = true
vim.opt.undolevels = 2000

-- Undo directory (STRING, not vim.opt)
local undodir = vim.fn.stdpath("data") .. "/undo"
vim.opt.undodir = undodir

-- Create undo directory if missing
pcall(function()
  if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
  end
end)

-----------------------------------------------------
-- Clipboard (local + SSH safe)
-----------------------------------------------------
-- Use system clipboard when available
vim.opt.clipboard = "unnamedplus"

-----------------------------------------------------
-- Split behavior
-----------------------------------------------------
-- Natural split directions
vim.opt.splitright = true
vim.opt.splitbelow = true

-----------------------------------------------------
-- Command-line completion
-----------------------------------------------------
-- Bash-like completion for :
vim.opt.wildmenu = true
vim.opt.wildmode = { "longest:full", "full" }

-----------------------------------------------------
-- Whitespace visibility (learning aid)
-----------------------------------------------------
vim.opt.list = true
vim.opt.listchars = {
  tab = ">-",
  trail = ".",
  nbsp = "+",
}

-----------------------------------------------------
-- Leader key
-----------------------------------------------------
vim.g.mapleader = " "

vim.opt.timeout = true
vim.opt.timeoutlen = 800

-----------------------------------------------------
-- Keymaps
-----------------------------------------------------
local map = vim.keymap.set

-- Clear search highlight
map("n", "<Esc><Esc>", "<cmd>nohlsearch<CR>", { silent = true })

-- Save / quit
map("n", "<leader>w", "<cmd>w<CR>")
map("n", "<leader>q", "<cmd>q<CR>")
map("n", "<leader>wq", "<cmd>wq<CR>")
map("n", "<leader>Q", "<cmd>q!<CR>")

-- Keep search results centered
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Maintain selection while indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Window navigation (tmux-friendly)
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Fast escape
map("i", "jk", "<Esc>")

-----------------------------------------------------
-- Toggles (learning helpers)
-----------------------------------------------------
-- Relative numbers
map("n", "<leader>n", function()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
end)

-- Cursor line
map("n", "<leader>c", function()
  vim.opt.cursorline = not vim.opt.cursorline:get()
end)

-- Whitespace visibility
map("n", "<leader>l", function()
  vim.opt.list = not vim.opt.list:get()
end)

-----------------------------------------------------
-- Commenting (NO plugins)
-----------------------------------------------------
-- Toggle comment on current line
map("n", "<leader>/", function()
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
end)

-- Comment visual selection
map("v", "<leader>/", function()
  local cs = vim.bo.commentstring
  if cs == "" then return end

  local comment = cs:gsub("%%s", "")
  local start = vim.fn.line("'<")
  local finish = vim.fn.line("'>")

  for i = start, finish do
    vim.fn.setline(i, comment .. " " .. vim.fn.getline(i))
  end
end)

-----------------------------------------------------
-- Quickfix navigation
-----------------------------------------------------
map("n", "]q", "<cmd>cnext<CR>")
map("n", "[q", "<cmd>cprev<CR>")
map("n", "<leader>qo", "<cmd>copen<CR>")
map("n", "<leader>qc", "<cmd>cclose<CR>")

-----------------------------------------------------
-- Terminal sanity
-----------------------------------------------------
-- Exit terminal mode easily
map("t", "<Esc>", [[<C-\><C-n>]])
map("t", "jk", [[<C-\><C-n>]])

-----------------------------------------------------
-- Autocommands
-----------------------------------------------------
-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
  end,
})

-- Equalize splits on resize
vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    vim.cmd("wincmd =")
  end,
})

-----------------------------------------------------
-- OSC52 clipboard (SSH copy support)
-----------------------------------------------------
if vim.env.SSH_CONNECTION or vim.env.SSH_TTY then
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
end

-- ==================================================
-- End of configuration
-- ==================================================
