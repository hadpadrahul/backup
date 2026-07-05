-- ==================================================
-- Neovim configuration
-- No plugins. Standalone, copy-and-use.
-- Personal + Server safe (SSH / TTY compatible)
-- Sane defaults an intermediate vim user would recognize.
-- ==================================================

-----------------------------------------------------
-- Leader key (must be set before ANY keymap that uses <leader>)
-----------------------------------------------------
vim.g.mapleader = " "
vim.opt.timeout = true
vim.opt.timeoutlen = 800

-----------------------------------------------------
-- Startup & filetypes
-----------------------------------------------------
vim.cmd("filetype plugin indent on")

-- Speed up Lua module loading (Neovim 0.9+, safe no-op on older versions)
pcall(vim.loader.enable)

-- vim.uv is the current name; vim.loop is the deprecated alias (pre-0.10)
local uv = vim.uv or vim.loop

-- Used below to gate on Neovim's built-in comment operator,
-- which only exists from 0.10 onward.
local has_builtin_comment = vim.fn.has("nvim-0.10") == 1

-----------------------------------------------------
-- UI & visibility (TTY-safe)
-----------------------------------------------------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.wrap = false            -- don't wrap long lines (logs, configs)
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"      -- prevent text shifting when signs appear
vim.opt.showcmd = true
vim.opt.mouse = "a"             -- mouse support in all modes

-- Enable true color only if Neovim was built with support for it.
if vim.fn.has("termguicolors") == 1 then
  vim.opt.termguicolors = true
end

-- Safe builtin colorscheme (ships with Neovim, never errors, no plugin needed)
pcall(vim.cmd.colorscheme, "habamax")

-----------------------------------------------------
-- Indentation (language-agnostic baseline)
-----------------------------------------------------
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

-- Don't auto-continue comment leaders when hitting o/O or wrapping text.
vim.opt.formatoptions:remove({ "c", "r", "o" })

-- Folding (indent-based, no plugins needed)
vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 99           -- start with all folds open

-- Per-filetype indent overrides. These fix the classic
-- "everything is 4 spaces even where the ecosystem convention is 2"
-- problem (web/config-y languages), and the classic "Neovim converted
-- my Makefile's tabs to spaces and now `make` fails" problem.
vim.api.nvim_create_autocmd("FileType", {
  desc = "2-space indent for common web/config/markup languages",
  pattern = {
    "yaml", "yml", "json", "jsonc", "html", "xml", "css", "scss",
    "javascript", "javascriptreact", "typescript", "typescriptreact",
    "lua", "toml", "vim",
  },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Makefiles require literal tabs, not spaces",
  pattern = "make",
  callback = function()
    vim.opt_local.expandtab = false
  end,
})

-----------------------------------------------------
-- Search behavior
-----------------------------------------------------
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- Live preview substitutions (:s/.../.../) as you type, no plugin needed.
vim.opt.inccommand = "split"

-----------------------------------------------------
-- Editing behavior
-----------------------------------------------------
vim.opt.hidden = true            -- switch buffers without saving
vim.opt.confirm = true           -- ask before destructive actions
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.updatetime = 200
vim.opt.lazyredraw = true        -- fewer redraws, helps over SSH
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 50         -- faster key recognition on high-latency links

-- Let :find search subdirectories (built-in fuzzy-ish file finder, no plugin)
vim.opt.path:append("**")
vim.opt.wildignore:append({ "*/node_modules/*", "*/.git/*" })

-----------------------------------------------------
-- Files & undo (server safe)
-----------------------------------------------------
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

vim.opt.undofile = true
vim.opt.undolevels = 2000

local undodir = vim.fn.stdpath("data") .. "/undo"
vim.opt.undodir = undodir

pcall(function()
  if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
  end
end)

-----------------------------------------------------
-- Clipboard (local + SSH safe)
-----------------------------------------------------

-- Use the system clipboard whenever it's available.
if vim.fn.has("clipboard") == 1 then
  vim.opt.clipboard = "unnamedplus"
end

-- Over SSH, use OSC52 so yanks reach the LOCAL machine's clipboard.
if vim.env.SSH_CONNECTION then
  local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")

  if ok then
    -- Route clipboard operations through OSC52.
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

    -- Fallback: explicitly push every yank over OSC52 too. This makes
    -- normal yanks (y, yy, visual y, etc.) reliably reach the local
    -- clipboard, even if the clipboard provider isn't triggered.
    local osc52_group = vim.api.nvim_create_augroup("OSC52Clipboard", {
      clear = true,
    })

    vim.api.nvim_create_autocmd("TextYankPost", {
      group = osc52_group,
      desc = "Copy yanks to local clipboard via OSC52",
      callback = function()
        local contents = vim.v.event.regcontents
        if contents and #contents > 0 then
          osc52.copy("+")(contents)
          osc52.copy("*")(contents)
        end
      end,
    })
  end
end

-----------------------------------------------------
-- Split behavior
-----------------------------------------------------
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.diffopt:append("vertical")
vim.opt.diffopt:append("linematch:60")

-----------------------------------------------------
-- Command-line completion
-----------------------------------------------------
vim.opt.wildmenu = true
vim.opt.wildmode = { "longest:full", "full" }

-----------------------------------------------------
-- Insert-mode completion (built-in Ctrl-N/Ctrl-P, no plugin)
-----------------------------------------------------
vim.opt.completeopt = { "menuone", "noselect" }

-----------------------------------------------------
-- Whitespace visibility (handy while learning/debugging files)
-----------------------------------------------------
vim.opt.list = true
vim.opt.listchars = {
  tab = ">-",
  trail = ".",
  nbsp = "+",
}

-----------------------------------------------------
-- Netrw (built-in file explorer -- the file browser when you have no plugins)
-----------------------------------------------------
vim.g.netrw_banner = 0        -- hide the help banner at the top
vim.g.netrw_liststyle = 3     -- tree-style listing
vim.g.netrw_winsize = 25      -- explorer takes 25% of the window width
vim.g.netrw_browse_split = 0  -- open files in the same window by default

-----------------------------------------------------
-- Keymaps (standard, low-surprise -- safe if you only know basic Vim)
-----------------------------------------------------
local map = vim.keymap.set

-- Clear search highlight
map("n", "<Esc><Esc>", "<cmd>nohlsearch<CR>", { silent = true, desc = "Clear search highlight" })

-- Save / quit
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
map("n", "<leader>wq", "<cmd>wq<CR>", { desc = "Save and quit" })
map("n", "<leader>Q", "<cmd>q!<CR>", { desc = "Quit without saving" })

-- File explorer toggle: open netrw normally, close it if you're already inside it.
map("n", "<leader>e", function()
  if vim.bo.filetype == "netrw" then
    vim.cmd("silent! keepalt bd")
  else
    vim.cmd("Explore")
  end
end, { desc = "Toggle file explorer" })

-- Keep search results centered
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Maintain selection while indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Window navigation (tmux-friendly)
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to window below" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to window above" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-----------------------------------------------------
-- Commenting
-----------------------------------------------------
-- Neovim 0.10+ ships a built-in comment operator:
--   gcc  toggle the current line      (normal mode)
--   gc   toggle the selection         (visual mode)
--   gc{motion}  toggle via a motion   (normal mode)
-- We remap <leader>/ onto it for muscle memory.
if has_builtin_comment then
  map("n", "<leader>/", "gcc", { remap = true, silent = true, desc = "Toggle comment (line)" })
  map("v", "<leader>/", "gc", { remap = true, silent = true, desc = "Toggle comment (selection)" })
else
  -- Fallback for Neovim < 0.10.
  -- Supports both single-line (normal mode) and multi-line (visual mode)
  -- toggling, and understands two-part comment strings like HTML's
  -- "<!-- %s -->", not just single-prefix ones like "// %s".
  local function comment_lines(start_line, end_line)
    local cs = vim.bo.commentstring
    if not cs or cs == "" then
      vim.notify(
        "No commentstring set for filetype '" .. vim.bo.filetype .. "'",
        vim.log.levels.WARN
      )
      return
    end

    local left, right = cs:match("^(.-)%%s(.-)$")
    if not left then
      return
    end
    left = left:gsub("%s+$", "")
    right = right:gsub("^%s+", "")

    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

    -- Decide comment vs uncomment from whether every non-blank line
    -- already starts with the comment prefix.
    local all_commented = true
    for _, l in ipairs(lines) do
      local trimmed = l:match("^%s*(.-)%s*$")
      if trimmed ~= "" and not trimmed:match("^" .. vim.pesc(left)) then
        all_commented = false
        break
      end
    end

    for i, l in ipairs(lines) do
      local indent, content = l:match("^(%s*)(.*)$")
      if content ~= "" then
        if all_commented then
          content = content:gsub("^" .. vim.pesc(left) .. "%s?", "", 1)
          if right ~= "" then
            content = content:gsub("%s?" .. vim.pesc(right) .. "$", "", 1)
          end
        else
          content = left .. " " .. content
          if right ~= "" then
            content = content .. " " .. right
          end
        end
        lines[i] = indent .. content
      end
    end

    vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
  end

  map("n", "<leader>/", function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    comment_lines(row, row)
  end, { silent = true, desc = "Toggle comment (line)" })

  map("v", "<leader>/", function()
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    comment_lines(start_line, end_line)
  end, { silent = true, desc = "Toggle comment (selection)" })
end

-----------------------------------------------------
-- Toggles (handy, no dependencies)
-----------------------------------------------------
map("n", "<leader>n", function()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = "Toggle relative line numbers" })

map("n", "<leader>c", function()
  vim.opt.cursorline = not vim.opt.cursorline:get()
end, { desc = "Toggle cursorline" })

map("n", "<leader>l", function()
  vim.opt.list = not vim.opt.list:get()
end, { desc = "Toggle whitespace visibility" })

-----------------------------------------------------
-- Quickfix navigation
-----------------------------------------------------
map("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix item" })
map("n", "[q", "<cmd>cprev<CR>", { desc = "Previous quickfix item" })
map("n", "<leader>qo", "<cmd>copen<CR>", { desc = "Open quickfix list" })
map("n", "<leader>qc", "<cmd>cclose<CR>", { desc = "Close quickfix list" })

-----------------------------------------------------
-- Terminal sanity
-----------------------------------------------------
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-----------------------------------------------------
-- Personal-preference mappings
-----------------------------------------------------
-- Escaping insert/terminal mode by typing "jk" is a popular habit, but it
-- means literally typing the letters j-then-k anywhere (prose, commit
-- messages, shell commands in :terminal) will unexpectedly bail you out.
-- Kept here because it existed in one of the source configs.
map("i", "jk", "<Esc>")
-- map("t", "jk", [[<C-\><C-n>]])

-----------------------------------------------------
-- Autocommands
-----------------------------------------------------
-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Briefly highlight yanked text",
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
  end,
})

-- Equalize splits on resize
vim.api.nvim_create_autocmd("VimResized", {
  desc = "Keep splits equal size on terminal resize",
  callback = function()
    vim.cmd("wincmd =")
  end,
})

-- Restore cursor to last known position when reopening a file
vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Restore cursor position when reopening a file",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Disable heavy features for large files
vim.api.nvim_create_autocmd("BufReadPre", {
  desc = "Disable heavy features for very large files",
  callback = function()
    local max_filesize = 1024 * 1024 -- 1MB
    local ok, stats = pcall(uv.fs_stat, vim.api.nvim_buf_get_name(0))

    if ok and stats and stats.size > max_filesize then
      vim.opt_local.syntax = "off"
      vim.opt_local.swapfile = false
      vim.opt_local.undofile = false
    end
  end,
})

-- ==================================================
-- End of configuration
-- ==================================================

